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

# install JBoss and config
sudo wget -q http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
tar -xzvf jboss-as-7.1.1.Final.tar.gz -C /opt
sudo useradd -r jboss -d /opt/jboss-as-7.1.1.Final
sudo chown -R jboss:jboss /opt/jboss-as-7.1.1.Final
#sudo wget -q http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip
#unzip jboss-as-7.1.1.Final.zip -d /opt
cd /opt/jboss-as-7.1.1.Final/bin
./add-user.sh admin admin
sed -i -e 's,<inet-address value="${jboss.bind.address:127.0.0.1}"/>,<any-ip4-address/>,g' /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -e 's,<inet-address value="${jboss.bind.address.management:127.0.0.1}"/>,<any-ip4-address/>,g' /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -e 's,JBOSS_HOME=/usr/share/jboss-as,JBOSS_HOME=/opt/jboss-as-7.1.1.Final,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sudo cp /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh /etc/init.d/jboss
sudo chmod -R 755 /etc/init.d/jboss
mkdir /etc/jboss-as
sudo echo "
JBOSS_HOME=/opt/jboss-as-7.1.1.Final
JBOSS_CONSOLE_LOG=/var/log/jboss-as/jboss-console.log
JBOSS_USER=jboss" >> /etc/jboss-as/jboss-as.conf
service jboss start
chkconfig jboss on
