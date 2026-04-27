# 🛠️ perfect-wordpress - Fast WordPress setup for servers

[![Download](https://img.shields.io/badge/Download-Visit%20GitHub%20Page-blue?style=for-the-badge&logo=github)](https://github.com/Rampant-drawer469/perfect-wordpress)

## 📦 What this is

perfect-wordpress is a setup tool for WordPress on Ubuntu 24.04 and Debian 13. It helps you build a full web server stack with Nginx, PHP-FPM, MariaDB, Redis, SSL, and Fail2ban.

Use it when you want a ready WordPress server without setting up each part by hand.

## ✅ What you need

- A fresh Ubuntu 24.04 or Debian 13 server
- Root access or a user with sudo rights
- A domain name that points to your server
- An active internet connection
- Basic access to your server through SSH

## 🚀 Download and setup

Visit this page to download and use the installer:

https://github.com/Rampant-drawer469/perfect-wordpress

If you use the page above, follow the steps on the repository to get the latest version and run the setup on your server.

## 🧰 What gets installed

This installer sets up the main parts needed for a WordPress site:

- Nginx for the web server
- PHP-FPM for PHP support
- MariaDB for the database
- Redis for better cache handling
- SSL with Let’s Encrypt
- Fail2ban for login protection
- WordPress for the site itself

## 🖥️ Best use case

This tool fits users who want a clean server setup for:

- A personal blog
- A business site
- A local development copy of WordPress
- A small production site
- A new server that needs a standard WordPress stack

## 📋 Before you start

Check these items before you run the installer:

1. Your domain name points to the server IP.
2. Port 80 and port 443 are open.
3. No other web server is already using Nginx ports.
4. You can log in as a user with admin rights.
5. Your server has enough disk space for WordPress, logs, and database files.

A small server can work for a basic site. A larger site needs more memory and storage.

## 🪜 How to use it

1. Open the GitHub page.
2. Get the latest installer files from the repository.
3. Copy the files to your Ubuntu or Debian server.
4. Open a terminal on the server.
5. Go to the folder where the files are stored.
6. Make the script ready to run.
7. Start the installer with sudo.
8. Follow the prompts on screen.
9. Enter your domain name when asked.
10. Wait for the setup to finish.

## 🔐 What the installer does for security

The setup adds common server protections:

- SSL to encrypt site traffic
- Fail2ban to block repeated login abuse
- A standard server layout that keeps services separate
- Safe defaults for WordPress hosting

This helps reduce basic attack risk and keeps the server easier to manage.

## 🌐 After setup

When the install ends, you should be able to:

- Open your WordPress site in a browser
- Log in to the WordPress dashboard
- Change the site title and theme
- Add posts and pages
- Install WordPress plugins

If your domain and SSL are set up right, your site should load with HTTPS.

## 🧾 Common checks

If the site does not open, check these items:

- The domain points to the right server
- Nginx is running
- PHP-FPM is running
- MariaDB is running
- DNS changes have finished
- The SSL certificate was issued for the correct domain

If WordPress loads but feels slow, Redis cache can help reduce load on the database.

## 🧩 Included topic areas

This project focuses on these areas:

- bash
- debian
- letsencrypt
- lightweight
- mariadb
- nginx
- php
- redis
- ubuntu
- wordpress
- wordpress-development
- wordpress-installer

## 🛠️ Good fit for

- Users who want a repeatable WordPress server setup
- System admins who want a simple install path
- Developers who need a fresh WordPress test site
- People who want a standard stack with SSL and cache support

## 📁 Basic folder flow

A normal setup from this project follows a simple path:

1. Download or copy the repository files
2. Run the setup script
3. Let it install the server packages
4. Enter the site details
5. Finish the WordPress install
6. Open the site in a browser
7. Sign in to the WordPress dashboard

## 🔍 What to expect in the dashboard

After setup, the WordPress admin area lets you:

- Write posts
- Edit pages
- Change the theme
- Add users
- Install plugins
- Adjust site settings
- Manage media files

## 🧪 Server stack layout

This installer builds a common Linux web stack:

- Nginx handles web traffic
- PHP-FPM runs WordPress PHP code
- MariaDB stores site data
- Redis helps with caching
- Let’s Encrypt adds HTTPS
- Fail2ban watches for bad login patterns

## 💡 Tips for a smooth setup

- Use a fresh server for the cleanest result
- Use a domain name, not just an IP address
- Keep your server time correct
- Use strong passwords for the WordPress admin account
- Save your database details in a safe place

## 🧭 Where to get the files

Use the GitHub page here:

https://github.com/Rampant-drawer469/perfect-wordpress

Go to that page, get the installer files, and run them on your Ubuntu 24.04 or Debian 13 server

## 🧱 Common setup path for new users

If this is your first time setting up WordPress on a server, use this order:

1. Buy or use a domain
2. Point the domain to the server
3. Open the GitHub page
4. Download the project files
5. Move them to the server
6. Run the install script
7. Complete the WordPress setup in the browser
8. Log in and start editing your site