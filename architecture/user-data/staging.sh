#!/bin/bash
set -euo pipefail

dnf update -y
dnf install nginx -y

cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>INC-003 Staging</title>
</head>
<body>
    <h1>STAGING</h1>
    <p>Environment: STAGING</p>
    <p>Hostname: staging.huche.com.br</p>
    <p>Project: INC-003</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx