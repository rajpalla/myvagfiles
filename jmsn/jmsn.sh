export DEBIAN_FRONTEND="noninteractive"
sudo apt-get update
echo mysql-server-5.7 mysql-server/root_password password pass | debconf-set-selections
echo mysql-server-5.7 mysql-server/root_password_again password pass | debconf-set-selections
sudo apt-get -y install mysql-server zip unzip

# Installing jdk-8.0.112 and Its Configuration
sudo wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz
sudo mkdir /opt/jdk
tar -xzvf jdk-8u112-linux-x64.tar.gz -C /opt/jdk
sudo update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_112/bin/java 100
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_112/bin/javac 100
sudo update-alternatives --display java
sudo update-alternatives --display javac
java -version

## Installing Maven and Its Configuring ##
# Method 1
sudo wget -q http://redrockdigimark.com/apachemirror/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -xzvf apache-maven-3.3.9-bin.tar.gz -C /opt/
sudo update-alternatives --install /usr/bin/mvn maven /opt/apache-maven-3.3.9/bin/mvn 1001
mvn -v
# Method 2
#sudo wget -q http://redrockdigimark.com/apachemirror/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
#tar -xzvf apache-maven-3.3.9-bin.tar.gz -C /usr/local
#sudo ln -s /usr/local/apache-maven-3.3.9/bin/mvn /usr/bin/mvn
#echo "export M2_HOME=/usr/local/apache-maven-3.3.9" >> /etc/.profile
#echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/.profile
#source /etc/profile

## Installing SonarQube, Its MySql Database and Its Configuration by editing sonar.properties file ##
# Create Mysql Database for SonarQube
mysql -uroot -ppass -e "CREATE DATABASE sonar /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -uroot -ppass -e "CREATE USER sonar IDENTIFIED BY 'sonar';"
mysql -uroot -ppass -e "GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';"
mysql -uroot -ppass -e "GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';"
mysql -uroot -ppass -e "FLUSH PRIVILEGES;"
# Installing SonarQube and Its Configuration by editing sonar.properties file
sudo wget -q /home/ubuntu/ https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.2.zip
cd /home/ubuntu
unzip sonarqube-6.2.zip -d /opt
sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube-6.2/conf/sonar.properties
sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/g' /opt/sonarqube-6.2/conf/sonar.properties
sed -i 's/#sonar.jdbc.url=jdbc:mysql:\/\/localhost:3306\/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance/sonar.jdbc.url=jdbc:mysql:\/\/localhost:3306\/sonar?useUnicode=true\&characterEncoding=utf8\&rewriteBatchedStatements=true\&useConfigs=maxPerformance/g' /opt/sonarqube-6.2/conf/sonar.properties 
sed -i 's/#sonar.web.context=/sonar.web.context=\/sonar/g' /opt/sonarqube-6.2/conf/sonar.properties
sed -i 's/#sonar.web.port=9000/sonar.web.port=9000/g' /opt/sonarqube-6.2/conf/sonar.properties
# Implementing SonarQube server as a service
sudo cp /opt/sonarqube-6.2/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
sed -i '/# Wrapper/i\SONAR_HOME=\/opt\/sonarqube-6.2\nPLATFORM=linux-x86-64' /etc/init.d/sonar
sed -i 's/WRAPPER_CMD=\".\/wrapper\"/WRAPPER_CMD=\"${SONAR_HOME}\/bin\/${PLATFORM}\/wrapper\"/g' /etc/init.d/sonar
sed -i 's/WRAPPER_CONF=\"..\/..\/conf\/wrapper.conf\"/WRAPPER_CONF=\"${SONAR_HOME}\/conf\/wrapper.conf\"/g' /etc/init.d/sonar
sed -i 's/PIDDIR=\".\"/PIDDIR=\"\/var\/run\"/g' /etc/init.d/sonar
sudo update-rc.d -f sonar remove
sudo chmod 755 /etc/init.d/sonar
sudo update-rc.d sonar defaults
sudo /opt/sonarqube-6.2/bin/linux-x86-64/sonar.sh start
sudo systemctl status sonar
sudo systemctl stop sonar
sudo systemctl start sonar

# Installing Nexus and Its Configuration
sudo wget -q https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.2.0-01-unix.tar.gz
tar xzvf nexus-3.2.0-01-unix.tar.gz -C /opt/
sudo useradd nexus
echo 'export NEXUS_HOME="/opt/nexus-3.2.0-01"' >> ~/.bashrc
sed -i 's/#run_as_user=""/run_as_user="nexus"/g' /opt/nexus-3.2.0-01/bin/nexus.rc
sudo ln -s /opt/nexus-3.2.0-01/bin/nexus /etc/init.d/nexus
sudo chmod 775 /opt/nexus-3.2.0-01/bin/nexus
sudo chown -R nexus:nexus /opt/nexus-3.2.0-01/ /opt/nexus-3.2.0-01/bin/ /opt/sonatype-work/
cd /etc/init.d
sudo update-rc.d nexus defaults
sudo service nexus start
sudo systemctl status nexus








