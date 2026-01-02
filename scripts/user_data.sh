#!/usr/bin/env bash
set -euo pipefail
# set -x  # Uncomment for debugging

AWS_REGION="${AWS_REGION:-eu-central-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"

# Logging functions
log_info()  { echo "[INFO]  $(date +'%Y-%m-%d %H:%M:%S') - $*"; }
log_error() { echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $*" >&2; }
fail()      { log_error "$*"; exit 1; }


# Check dependencies
check_dependencies() {
    for cmd in yum systemctl amazon-linux-extras aws; do
        command -v "$cmd" >/dev/null 2>&1 || fail "$cmd is required but not installed."
    done
}


# System update and package installation
install_packages() {
    log_info "Updating system packages..."
    yum update -y

    log_info "Installing Apache..."
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd

    log_info "Installing PHP 8.0..."
    amazon-linux-extras enable php8.0
    yum install -y php php-cli php-common php-pdo php-mysqlnd
}


# Fetch DB credentials from SSM
fetch_db_credentials() {
    log_info "Fetching database credentials from SSM..."

    DB_ENDPOINT=$(aws ssm get-parameter \
        --name "/app/db/endpoint" \
        --query "Parameter.Value" \
        --output text --region "$AWS_REGION")
    DB_NAME=$(aws ssm get-parameter \
        --name "/app/db/name" \
        --query "Parameter.Value" \
        --output text --region "$AWS_REGION")
    DB_USER=$(aws ssm get-parameter \
        --name "/app/db/username" \
        --query "Parameter.Value" \
        --output text --region "$AWS_REGION")
    DB_PASS=$(aws ssm get-parameter \
        --name "/app/db/password" \
        --with-decryption \
        --query "Parameter.Value" \
        --output text --region "$AWS_REGION")

    DB_HOST=$(echo "$DB_ENDPOINT" | cut -d: -f1)
    DB_PORT=$(echo "$DB_ENDPOINT" | cut -d: -f2)
}


# Configure Apache environment variables
configure_apache_env() {
    log_info "Configuring Apache environment variables..."
    cat > /etc/httpd/conf.d/app_env.conf <<EOF
SetEnv DB_HOST "$DB_HOST"
SetEnv DB_PORT "$DB_PORT"
SetEnv DB_NAME "$DB_NAME"
SetEnv DB_USER "$DB_USER"
SetEnv DB_PASS "$DB_PASS"
EOF
}


# Cleanup default Apache pages
cleanup_apache() {
    log_info "Cleaning up default Apache test pages..."
    rm -f /var/www/html/index.html
    rm -f /etc/httpd/conf.d/welcome.conf
}


# Deploy PHP application
deploy_php_app() {
    log_info "Creating PHP application..."
    cat > /var/www/html/index.php <<'PHP'
<?php
# Fetch environment variables
$db_host = getenv('DB_HOST');
$db_port = getenv('DB_PORT');
$db_name = getenv('DB_NAME');
$db_user = getenv('DB_USER');
$db_pass = getenv('DB_PASS');

$db_connected = false;
$error_message = '';
$total_visits = 0;
$recent = null;

function imds($path) {
    $token = shell_exec("curl -s -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600'");
    return shell_exec("curl -s -H 'X-aws-ec2-metadata-token: $token' http://169.254.169.254/latest/meta-data/$path");
}

$instance_id        = trim(imds("instance-id"));
$availability_zone  = trim(imds("placement/availability-zone"));
$instance_type      = trim(imds("instance-type"));
$private_ip         = trim(imds("local-ipv4"));

try {
    $dsn = sprintf("mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4", $db_host, $db_port, $db_name);
    $pdo = new PDO($dsn, $db_user, $db_pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    $pdo->exec("CREATE TABLE IF NOT EXISTS visitors (id INT AUTO_INCREMENT PRIMARY KEY, visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, instance_id VARCHAR(50), ip_address VARCHAR(50))");

    $stmt = $pdo->prepare("INSERT INTO visitors (instance_id, ip_address) VALUES (?, ?)");
    $stmt->execute([$instance_id, $_SERVER['REMOTE_ADDR']]);

    $total_visits = $pdo->query("SELECT COUNT(*) FROM visitors")->fetchColumn();
    $recent = $pdo->query("SELECT visit_time, instance_id, ip_address FROM visitors ORDER BY visit_time DESC LIMIT 10");

    $db_connected = true;
} catch (Exception $e) {
    $error_message = $e->getMessage();
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier AWS Application</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f4f4f4; }
        h1 { color: #333; }
        .status { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .status.success { background-color: #e0f8e9; color: #2a7a3a; }
        .status.error { background-color: #fde0e0; color: #a33a3a; }
        .info-grid { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 20px; }
        .info-card { background: #fff; padding: 15px; border-radius: 5px; flex: 1 1 200px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .visitors table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .visitors th, .visitors td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .visitors th { background: #eee; }
    </style>
</head>
<body>
    <h1>3-Tier AWS Application</h1>

    <?php if ($db_connected): ?>
        <div class="status success">
            <strong>Database Connected Successfully!</strong>
            <p>All three tiers are operational</p>
        </div>
    <?php else: ?>
        <div class="status error">
            <strong>Database Connection Failed</strong>
            <p><?php echo htmlspecialchars($error_message); ?></p>
        </div>
    <?php endif; ?>

    <div class="info-grid">
        <div class="info-card">
            <h3>Instance ID</h3>
            <p><?php echo htmlspecialchars($instance_id ?: 'Unknown'); ?></p>
        </div>
        <div class="info-card">
            <h3>Availability Zone</h3>
            <p><?php echo htmlspecialchars($availability_zone ?: 'Unknown'); ?></p>
        </div>
        <div class="info-card">
            <h3>Instance Type</h3>
            <p><?php echo htmlspecialchars($instance_type ?: 'Unknown'); ?></p>
        </div>
        <div class="info-card">
            <h3>Private IP</h3>
            <p><?php echo htmlspecialchars($private_ip ?: 'Unknown'); ?></p>
        </div>
    </div>

    <?php if ($db_connected): ?>
        <div class="visitors">
            <h3>Visitor Statistics</h3>
            <p><strong>Total Visits:</strong> <?php echo $total_visits; ?></p>

            <table>
                <thead>
                    <tr>
                        <th>Visit Time</th>
                        <th>Instance ID</th>
                        <th>IP Address</th>
                    </tr>
                </thead>
                <tbody>
                    <?php while($row = $recent->fetch(PDO::FETCH_ASSOC)): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($row['visit_time']); ?></td>
                            <td><?php echo htmlspecialchars($row['instance_id']); ?></td>
                            <td><?php echo htmlspecialchars($row['ip_address']); ?></td>
                        </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</body>
</html>
PHP

    # Health check endpoint
    cat > /var/www/html/health.php <<'PHP'
<?php http_response_code(200); echo "OK"; ?>
PHP
}


# Set permissions and restart Apache
finalize_setup() {
    log_info "Setting permissions and restarting Apache..."
    chown -R apache:apache /var/www/html
    chmod -R 755 /var/www/html
    systemctl restart httpd
}


# Main function
main() {
    check_dependencies
    install_packages
    fetch_db_credentials
    configure_apache_env
    cleanup_apache
    deploy_php_app
    finalize_setup
    log_info "Application deployment completed successfully!"
}

# Run main
main
