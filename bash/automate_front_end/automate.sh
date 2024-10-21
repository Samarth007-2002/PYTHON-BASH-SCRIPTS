#!/bin/bash

LOG_DIR="logs"

# Create the logs directory if it doesn't exist
mkdir -p $LOG_DIR

read -p "Enter the branch name: " branch
read -p "Enter the GitHub username: " username
read -p "Enter the access token: " token
read -p "Enter the repository URL without 'https://': " repo_url

# Clone the repository
git clone --branch "$branch" https://"$username":"$token"@"$repo_url" project

# Update system packages
sudo apt update | tee -a $LOG_DIR/update.log

# Install Node.js
sudo apt install nodejs -y | tee -a $LOG_DIR/nodejs_install.log

# Install npm
sudo apt install npm -y | tee -a $LOG_DIR/npm_install.log

# Install PM2 globally
sudo npm install -g pm2

# Change to the project directory
cd project

# Install project dependencies
npm install | tee -a $LOG_DIR/npm_dependencies_install.log

# Install Prisma and Prisma Client
npm install prisma @prisma/client | tee -a $LOG_DIR/prisma_install.log

# Generate Prisma client, specify schema if necessary
npx prisma generate | tee -a $LOG_DIR/prisma_generate.log

# Run the Next.js application
pm2 start npm --name "app-dev" -- run dev | tee -a $LOG_DIR/nextjs_run.log

pm2 start npx --name "json-server" -- json-server --watch db.json --port 3001 &
