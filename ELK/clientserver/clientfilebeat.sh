echo 'ubuntu:ubuntu' | chpasswd
sudo apt-get update
sudo apt-get install -y tree unzip sshpass nginx apache2-utils php-fpm tomcat8 tomcat8-docs tomcat8-admin tomcat8-examples

# Installing jdk-8.0.112 and Its Configuration
sudo wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz
sudo mkdir /opt/jdk
tar -xzvf jdk-8u112-linux-x64.tar.gz -C /opt/jdk
# JDK Path setting
sudo update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_112/bin/java 1100
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_112/bin/javac 1100
sudo update-alternatives --display java
sudo update-alternatives --display javac
java -version

#Configure Tomcat8 and deploy jenkins.war
sudo echo -e '<tomcat-users>\n<user username="admin" password="password" roles="manager-gui,admin-gui"/>\n</tomcat-users>' > /etc/tomcat8/tomcat-users.xml
sudo systemctl restart tomcat8
sudo wget -q http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable/2.32.2/jenkins.war
sudo cp jenkins.war /var/lib/tomcat8/webapps/
sudo chmod -R 755 /var/lib/tomcat8/*
sudo chown -R tomcat8:tomcat8 /var/lib/tomcat8/*
sudo mkdir /usr/share/tomcat8/.jenkins 
sudo chown -R tomcat8:tomcat8 /usr/share/tomcat8 /usr/share/tomcat8/.jenkins
sudo chmod -R 755 /usr/share/tomcat8 /usr/share/tomcat8/.jenkins
sudo systemctl restart tomcat8

#Install FileBeat and its Configuration
sudo mkdir -p /etc/pki/tls/certs
sudo mkdir -p /etc/pki/tls/private
sshpass -p "ubuntu" scp -o 'StrictHostKeyChecking no' ubuntu@192.168.33.44:/etc/pki/tls/certs/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
sshpass -p "ubuntu" scp -o 'StrictHostKeyChecking no' ubuntu@192.168.33.44:/etc/pki/tls/private/logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key
sudo wget -q https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.2.0-amd64.deb
sudo dpkg -i filebeat-5.2.0-amd64.deb
sudo echo '
filebeat.prospectors:
- input_type: syslog
  paths:
    - /var/log/auth.log
    - /var/log/syslog
    - /var/log/tomcat8/*.log
    #  - /var/log/*.log      
  document_type: syslog

filebeat.registry_file: /var/lib/filebeat/registry

output.logstash:
  hosts: ["192.168.33.44:5044"]
  bulk_max_size: 1024
  ssl.certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]
  ssl.certificate: "/etc/pki/tls/certs/logstash-forwarder.crt"
  ssl.key: "/etc/pki/tls/private/logstash-forwarder.key"
  
shipper:
  name: XYZ
logging:
  files:
    rotateeverybytes: 10485760 # = 10MB
' > /etc/filebeat/filebeat.yml
sudo systemctl enable filebeat
sudo systemctl restart filebeat
sudo systemctl status filebeat
