#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.
echo "[Let's start deploy app]"
sudo apt -y update
sleep 15
sudo apt -y update
sudo apt -y install apache2
sudo systemctl start apache2
sudo chown -R ubuntu:ubuntu /var/www/html
# sudo chmod +x *.sh
# ./deploy_app_v2.sh
sudo apt -y install cowsay
cowsay Mooooooooooo!
sleep 2

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://placekitten.com/600/400"></img></center>
  <center><h2>Hello Cloud!</h2></center>
  Welcome to Meow App Version-2. This app is deployed automatically by terraform cloud!.
  <!-- END -->

  </div>
  </body>
</html>
EOM

sudo systemctl restart apache2

echo "Script complete."
