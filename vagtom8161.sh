sudo apt-get update
sudo apt-get install -y tree apache2 default-jdk git maven tomcat8 tomcat8-docs tomcat8-admin tomcat8-examples
wget -q http://mirrors.jenkins-ci.org/war/latest/jenkins.war
sudo cp jenkins.war /var/lib/tomcat8/webapps/
sudo service tomcat8 restart
sudo mkdir /usr/share/tomcat8/.jenkins
sudo chmod -R 755 /usr/share/tomcat8/.jenkins
sudo chown -R tomcat8:nogroup /usr/share/tomcat8/.jenkins
sudo chmod -R 755 /var/lib/tomcat8/
sudo chown -R tomcat8:nogroup /var/lib/tomcat8/
sudo chmod -R 755 /usr/share/tomcat8/
sudo chown -R tomcat8:nogroup /usr/share/tomcat8/
sudo chmod -R 755 /etc/tomcat8
sudo chown -R $USER:$USER /etc/tomcat8/
sudo chown -R $USER:$USER /etc/tomcat8/tomcat-users.xml
echo -e '<tomcat-users>\n<user username="admin" password="password" roles="manager-gui,admin-gui"/>\n</tomcat-users>' > /etc/tomcat8/tomcat-users.xml
sudo service tomcat8 restart
# wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
# sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
# sudo apt-get update
# sudo apt-get install -y jenkins
# sed -i 's/6060/8080/g' /etc/default/jenkins
# sudo service jenkins restart

