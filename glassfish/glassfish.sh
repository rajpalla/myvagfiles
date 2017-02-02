sudo apt-get update
sudo apt-get install -y zip unzip
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

# install glassfish and config
sudo wget -q http://download.java.net/glassfish/4.1.1/release/glassfish-4.1.1.zip
sudo wget -q https://netix.dl.sourceforge.net/project/openmrs/releases/OpenMRS_Platform_2.0.2/openmrs.war
unzip glassfish-4.1.1.zip -d /opt
sudo addgroup --system glassfish
sudo adduser --system --shell /bin/bash --ingroup glassfish glassfish
sudo chown -R glassfish:glassfish /opt/glassfish4
sudo chmod -R 755 /opt/glassfish4 /opt/glassfish4/bin
sudo echo "export PATH=/opt/glassfish4/bin:$PATH" >> ~/.profile
cd /opt/glassfish4/bin
./asadmin start-domain
sudo echo 'AS_ADMIN_PASSWORD=
           AS_ADMIN_NEWPASSWORD=admin' >> /opt/tmpfile
./asadmin --user admin --passwordfile=/opt/tmpfile change-admin-password
sudo echo 'AS_ADMIN_PASSWORD=admin' >> /opt/pwdfile
./asadmin --user admin --passwordfile=/opt/pwdfile enable-secure-admin
./asadmin restart-domain
./asadmin --passwordfile=/opt/pwdfile deploy /home/ubuntu/openmrs.war
sudo wget -q -P /opt/glassfish4/glassfish/domains/domain1/autodeploy/ http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable/2.32.2/jenkins.war
sudo chmod -R 755 /opt/glassfish4/glassfish/domains/domain1/autodeploy/jenkins.war
sudo chown -R glassfish:glassfish /opt/glassfish4/glassfish/domains/domain1/autodeploy/jenkins.war
./asadmin restart-domain
