sudo apt-get update

# Installing jdk-8.0.112 and Its Configuration
sudo wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz
sudo mkdir /opt/jdk
tar -xzvf jdk-8u112-linux-x64.tar.gz -C /opt/jdk
# JDK Path setting
sudo update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_112/bin/java 1100
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_112/bin/javac 1100
sudo update-alternatives --display java
java -version

# install wildfly and config
sudo wget -q http://download.jboss.org/wildfly/10.1.0.Final/wildfly-10.1.0.Final.tar.gz
tar -xzvf wildfly-10.1.0.Final.tar.gz -C /opt
sudo useradd -s /bin/sh wildfly -d /opt/wildfly-10.1.0.Final
sudo chown -R wildfly:wildfly /opt/wildfly-10.1.0.Final
sudo chmod 0755 /opt/wildfly-10.1.0.Final
sudo echo '
export JAVA_HOME="/opt/jdk/jdk1.8.0_112"
export PATH=$JAVA_HOME/bin:$PATH
export JBOSS_HOME="/opt/wildfly-10.1.0.Final"
export PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH' >> ~/.bashrc
cd /opt/wildfly-10.1.0.Final/bin
./add-user.sh --silent=true useradmin passadmin > /tmp/capture.log
#./standalone.sh -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0&
sudo cp /opt/wildfly-10.1.0.Final/docs/contrib/scripts/init.d/wildfly.conf /etc/default/wildfly
sudo cp /opt/wildfly-10.1.0.Final/docs/contrib/scripts/init.d/wildfly-init-debian.sh /etc/init.d/wildfly
sed -i -e 's,<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" runtime-failure-causes-rollback="${jboss.deployment.scanner.rollback.on.failure:false}"/>,<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" deployment-timeout="600" auto-deploy-zipped="true" auto-deploy-exploded="true"/>,g' /opt/wildfly-10.1.0.Final/standalone/configuration/standalone-ha.xml
sed -i 's,127.0.0.1,0.0.0.0,g' /opt/wildfly-10.1.0.Final/standalone/configuration/standalone-ha.xml
sudo wget -q -P /opt/wildfly-10.1.0.Final/standalone/deployments http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable/2.32.2/jenkins.war
sudo echo '
JAVA_HOME="/opt/jdk/jdk1.8.0_112"
JBOSS_HOME="/opt/wildfly-10.1.0.Final"
JBOSS_USER=wildfly
JBOSS_MODE=standalone
JBOSS_CONFIG=standalone-ha.xml
JBOSS_DOMAIN_CONFIG=domain.xml
JBOSS_HOST_CONFIG=host-master.xml
STARTUP_WAIT=600
SHUTDOWN_WAIT=120
JBOSS_CONSOLE_LOG="/var/log/wildfly/console.log" ' >> /etc/default/wildfly
sudo chown root:root /etc/init.d/wildfly
sudo chmod 755 /etc/init.d/wildfly
sudo update-rc.d wildfly defaults
sudo update-rc.d wildfly enable
sudo systemctl start wildfly
sudo systemctl status wildfly
