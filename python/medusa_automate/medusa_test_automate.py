#!/bin/bash

# Redirect stdout and stderr to a log file
exec > >(tee -a /home/ubuntu/medusa_setup.log) 2>&1

cd /home/ubuntu
sudo apt update -y
sudo apt install -y nodejs npm
sudo npm install -g @medusajs/medusa-cli
sudo npm install pm2 -g
sudo apt install -y postgresql
sudo apt install -y git

# Create the PostgreSQL user and database
sudo -u postgres psql <<EOF2
CREATE USER medusa WITH PASSWORD 'medusa';
CREATE DATABASE medusa_db OWNER medusa;
GRANT ALL PRIVILEGES ON DATABASE medusa_db TO medusa;
EOF2

git clone https://github.com/medusajs/medusa-starter-default.git
cd medusa-starter-default
npm install

mv .env.template .env
echo "DATABASE_URL=postgres://medusa:medusa@localhost:5432/medusa_db" >> .env

npm run seed
npm run migrations

pm2 start npm --name "medusa" -- run start
pm2 startup
pm2 save
