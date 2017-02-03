sudo apt-get update
#sudo apt-get install -y openjdk-8-jdk
#java -version

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
sudo useradd -s /bin/sh jboss -d /opt/jboss-as-7.1.1.Final
sudo chown -R jboss:jboss /opt/jboss-as-7.1.1.Final
sudo echo '
export JAVA_HOME="/opt/jdk/jdk1.8.0_112"
export PATH=$JAVA_HOME/bin:$PATH
export JBOSS_HOME="/opt/jboss-as-7.1.1.Final"
export PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH' >> ~/.bashrc
cd /opt/jboss-as-7.1.1.Final/bin
./add-user.sh --silent=true useradmin passadmin > /tmp/capture.log
sed -i -e 's, \
<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000"/>, \
<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" deployment-timeout="240"/>,g' /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -e 's,<inet-address value="${jboss.bind.address:127.0.0.1}"/>,<any-ip4-address/>,g' /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i -e 's,<inet-address value="${jboss.bind.address.management:127.0.0.1}"/>,<any-ip4-address/>,g' /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sed -i "/CMD_PREFIX=''/a JBOSS_USER=jboss" /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,. /etc/init.d/functions,. /lib/lsb/init-functions,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,STARTUP_WAIT=30,STARTUP_WAIT=240,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,daemon --user,start-stop-daemon -user,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,echo -n $"Stopping $prog: ",echo -n "Stopping $prog: ",g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,let kwait=$SHUTDOWN_WAIT,kwait=$SHUTDOWN_WAIT,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,. /etc/rc.d/init.d/functions,. /lib/lsb/init-functions,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,export JAVA_HOME,export JAVA_HOME=/opt/jdk/jdk1.8.0_112,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,JBOSS_HOME=/usr/share/jboss-as,JBOSS_HOME=/opt/jboss-as-7.1.1.Final,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
sed -i -e 's,JBOSS_CONF="/etc/jboss-as/jboss-as.conf",JBOSS_CONF=/etc/jboss-as/jboss-as.conf,g' /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh
mkdir /etc/jboss-as
sudo echo "
JBOSS_HOME=/opt/jboss-as-7.1.1.Final
JBOSS_CONSOLE_LOG=/var/log/jboss-as/jboss-console.log
JBOSS_USER=jboss" >> /etc/jboss-as/jboss-as.conf
sudo cp /opt/jboss-as-7.1.1.Final/bin/init.d/jboss-as-standalone.sh /etc/init.d/jboss
sudo chmod ug+x /etc/init.d/jboss
sudo update-rc.d jboss defaults
sudo systemctl start jboss 
sudo systemctl stop jboss
sudo systemctl start jboss
sudo systemctl status jboss
