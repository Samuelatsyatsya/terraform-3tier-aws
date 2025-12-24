#!/bin/bash
# User Data Script for Web Application Tier
# This script installs and configures a simple PHP web application with MySQL connection

set -e

# Update system packages
yum update -y

# Install Apache web server
yum install -y httpd

# Install PHP and MySQL extension
yum install -y php php-mysqlnd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Configure database connection parameters
DB_ENDPOINT="${db_endpoint}"
DB_NAME="${db_name}"
DB_USERNAME="${db_username}"
DB_PASSWORD="${db_password}"

# Extract database host and port from endpoint
DB_HOST=$(echo $DB_ENDPOINT | cut -d: -f1)
DB_PORT=$(echo $DB_ENDPOINT | cut -d: -f2)

# Create a simple PHP application
cat > /var/www/html/index.php << 'PHPEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3-Tier Application</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 800px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            margin-bottom: 30px;
            text-align: center;
            font-size: 2.5em;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .info-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        .info-card h3 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 1.2em;
        }
        .info-card p {
            color: #666;
            word-break: break-all;
        }
        .status {
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            text-align: center;
        }
        .status.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .status.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .visitors {
            background: #e7f3ff;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .visitors h3 {
            color: #667eea;
            margin-bottom: 15px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #667eea;
            color: white;
        }
        tr:hover {
            background: #f5f5f5;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>3-Tier AWS Application</h1>
        
        <?php
        // Database configuration
        $db_host = getenv('DB_HOST') ?: 'DB_HOST_PLACEHOLDER';
        $db_port = getenv('DB_PORT') ?: 'DB_PORT_PLACEHOLDER';
        $db_name = getenv('DB_NAME') ?: 'DB_NAME_PLACEHOLDER';
        $db_user = getenv('DB_USER') ?: 'DB_USER_PLACEHOLDER';
        $db_pass = getenv('DB_PASS') ?: 'DB_PASS_PLACEHOLDER';
        
        # // Get instance metadata
        $instance_id = @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id');
        $availability_zone = @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone');
        $instance_type = @file_get_contents('http://169.254.169.254/latest/meta-data/instance-type');
        $private_ip = @file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4');
        
        // Try to connect to database
        $db_connected = false;
        $error_message = '';
        
        try {
            $conn = new mysqli($db_host, $db_user, $db_pass, $db_name, $db_port);
            
            if ($conn->connect_error) {
                throw new Exception($conn->connect_error);
            }
            
            $db_connected = true;
            
            // Create visitors table if not exists
            $create_table = "CREATE TABLE IF NOT EXISTS visitors (
                id INT AUTO_INCREMENT PRIMARY KEY,
                visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                instance_id VARCHAR(50),
                ip_address VARCHAR(50)
            )";
            $conn->query($create_table);
            
            // Log this visit
            $visitor_ip = $_SERVER['REMOTE_ADDR'];
            $insert_visit = $conn->prepare("INSERT INTO visitors (instance_id, ip_address) VALUES (?, ?)");
            $insert_visit->bind_param("ss", $instance_id, $visitor_ip);
            $insert_visit->execute();
            
            // Get total visits
            $result = $conn->query("SELECT COUNT(*) as total FROM visitors");
            $total_visits = $result->fetch_assoc()['total'];
            
            // Get recent visits
            $recent = $conn->query("SELECT * FROM visitors ORDER BY visit_time DESC LIMIT 5");
            
        } catch (Exception $e) {
            $error_message = $e->getMessage();
        }
        ?>
        
        <?php if ($db_connected): ?>
            <div class="status success">
                <strong>✓ Database Connected Successfully!</strong>
                <p>All three tiers are operational</p>
            </div>
        <?php else: ?>
            <div class="status error">
                <strong>✗ Database Connection Failed</strong>
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
                        <?php while($row = $recent->fetch_assoc()): ?>
                            <tr>
                                <td><?php echo $row['visit_time']; ?></td>
                                <td><?php echo htmlspecialchars($row['instance_id']); ?></td>
                                <td><?php echo htmlspecialchars($row['ip_address']); ?></td>
                            </tr>
                        <?php endwhile; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
        
        <?php if (isset($conn)) $conn->close(); ?>
    </div>
</body>
</html>
PHPEOF

# Replace placeholders with actual values in the PHP file
sed -i "s/DB_HOST_PLACEHOLDER/$DB_HOST/g" /var/www/html/index.php
sed -i "s/DB_PORT_PLACEHOLDER/$DB_PORT/g" /var/www/html/index.php
sed -i "s/DB_NAME_PLACEHOLDER/$DB_NAME/g" /var/www/html/index.php
sed -i "s/DB_USER_PLACEHOLDER/$DB_USERNAME/g" /var/www/html/index.php
sed -i "s/DB_PASS_PLACEHOLDER/$DB_PASSWORD/g" /var/www/html/index.php

# Set environment variables for PHP
cat > /etc/environment << EOF
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USERNAME
DB_PASS=$DB_PASSWORD
EOF

# Create a simple health check endpoint
cat > /var/www/html/health.php << 'EOF'
<?php
http_response_code(200);
echo "OK";
?>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache to apply changes
systemctl restart httpd

# Create a log file for troubleshooting
cat > /var/log/user-data.log << EOF
User Data Script Completed
Date: $(date)
DB_HOST: $DB_HOST
DB_PORT: $DB_PORT
DB_NAME: $DB_NAME
EOF

echo "Application deployment completed successfully!"