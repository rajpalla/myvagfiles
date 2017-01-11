sudo apt-get update
sudo apt-get install -y tree apache2 default-jdk git maven tomcat8 tomcat8-docs tomcat8-admin tomcat8-examples
sudo echo -e '<tomcat-users>\n<user username="admin" password="password" roles="manager-gui,admin-gui"/>\n</tomcat-users>' > /etc/tomcat8/tomcat-users.xml
sudo systemctl restart tomcat8
sudo wget -q http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable/2.32.1/jenkins.war
sudo cp jenkins.war /var/lib/tomcat8/webapps/
sudo chmod -R 755 /var/lib/tomcat8/*
sudo chown -R tomcat8:tomcat8 /var/lib/tomcat8/*
sudo mkdir /usr/share/tomcat8/.jenkins 
sudo chown -R tomcat8:tomcat8 /usr/share/tomcat8 /usr/share/tomcat8/.jenkins
sudo chmod -R 755 /usr/share/tomcat8 /usr/share/tomcat8/.jenkins
sudo systemctl restart tomcat8
#sudo cat /usr/share/tomcat8/.jenkins/secrets/initialAdminPassword
# wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
# sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
# sudo apt-get update
# sudo apt-get install -y jenkins
# sed -i 's/6060/8080/g' /etc/default/jenkins
# sudo service jenkins restart