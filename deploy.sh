#!/bin/bash

# 部署脚本 for Ubuntu 24.04
# 作者：你的名字
# 功能：自动部署家庭局域网管理系统

# 配置变量
PROJECT_NAME="HomeCenter"              # 项目名称
PROJECT_DIR="/home/$USER/$PROJECT_NAME"  # 项目目录
GIT_REPO="https://github.com/e703/HomeCenter.git"       # 你的Git仓库地址（如果有）
NODE_PORT=3000                     # Node.js应用监听的端口
DOMAIN="your_domain_or_ip"         # 你的域名或IP地址

# 检查是否以root用户运行
if [ "$EUID" -ne 0 ]; then
  echo "请以root用户运行此脚本"
  exit 1
fi

# 更新系统
echo "更新系统..."
apt update -y
apt upgrade -y

# 安装Node.js
echo "安装Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 安装Nginx
echo "安装Nginx..."
apt install -y nginx

# 安装PM2
echo "安装PM2..."
npm install -g pm2

# 克隆或上传项目
echo "部署项目..."
if [ -d "$PROJECT_DIR" ]; then
  echo "项目目录已存在，跳过克隆..."
else
  echo "克隆项目..."
  git clone "$GIT_REPO" "$PROJECT_DIR"
fi

# 进入项目目录
cd "$PROJECT_DIR"

# 安装项目依赖
echo "安装项目依赖..."
npm install

# 启动Node.js应用
echo "启动Node.js应用..."
pm2 start app.js --name "$PROJECT_NAME"
pm2 save
pm2 startup

# 配置Nginx反向代理
echo "配置Nginx反向代理..."
cat > /etc/nginx/sites-available/$PROJECT_NAME <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$NODE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# 启用Nginx配置
ln -sf /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# 配置防火墙
echo "配置防火墙..."
ufw allow 'Nginx Full'
ufw enable

# （可选）配置HTTPS
read -p "是否配置HTTPS？(y/n): " CONFIGURE_HTTPS
if [ "$CONFIGURE_HTTPS" = "y" ]; then
  echo "安装Certbot..."
  apt install -y certbot python3-certbot-nginx
  certbot --nginx -d $DOMAIN
  echo "HTTPS配置完成！"
fi

# 完成
echo "部署完成！"
echo "访问地址：http://$DOMAIN"
if [ "$CONFIGURE_HTTPS" = "y" ]; then
  echo "或 HTTPS 地址：https://$DOMAIN"
fi
