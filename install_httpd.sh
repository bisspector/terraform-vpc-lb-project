#!/bin/bash
sudo apt update
sudo apt -y install apache2
sudo systemctl start apache2
echo "<h1>${file_content}</h1>" | sudo tee /var/www/html/index.html
