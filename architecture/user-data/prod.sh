#!/bin/bash
set -euo pipefail

dnf update -y
dnf install nginx -y

cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>INC-003 Production</title>
</head>
<body>
    <h1>PRODUCTION</h1>
    <p>Environment: PROD</p>
    <p>Hostname: portal.huche.com.br</p>
    <p>Project: INC-003</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx