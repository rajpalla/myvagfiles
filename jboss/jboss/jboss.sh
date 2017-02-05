sudo apt-get update
sudo apt-get install -y openjdk-7-jdk
sudo update-alternatives --display java
java -version

# install JBoss and config
sudo wget -q http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
tar -xzvf jboss-as-7.1.1.Final.tar.gz -C /opt
sudo useradd -s /bin/sh jboss -d /opt/jboss-as-7.1.1.Final
sudo chown -R jboss:jboss /opt/jboss-as-7.1.1.Final
sudo echo '
export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/jre"
export PATH=$JAVA_HOME/bin:$PATH
export JBOSS_HOME="/opt/jboss-as-7.1.1.Final"
export PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH' >> ~/.bashrc
cd /opt/jboss-as-7.1.1.Final/bin
./add-user.sh --silent=true useradmin passadmin > /tmp/capture.log
#./standalone.sh -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0&
sed -i -e 's,<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000"/>,<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" deployment-timeout="240" auto-deploy-zipped="true" auto-deploy-exploded="true"/>,g' /opt/jboss-as-7.1.1.Final/standalone/configuration/standalone.xml
sudo wget -q -P /opt/jboss-as-7.1.1.Final/standalone/deployments http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable/2.32.2/jenkins.war
sudo echo '
#!/bin/sh

JBOSS_USER=jboss
JBOSS_HOME=/opt/jboss-as-7.1.1.Final

export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/jre/"
export PATH=$JAVA_HOME/bin:$PATH
export JBOSS_HOME="/opt/jboss-as-7.1.1.Final"
export PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$PATH

AS7_OPTS="$AS7_OPTS -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_HTTP_SEPARATORS_IN_V0=true"  
AS7_OPTS="$AS7_OPTS -Djboss.bind.address.management=0.0.0.0" 
AS7_OPTS="$AS7_OPTS -Djboss.bind.address=0.0.0.0"

start() {
echo "Starting JBoss AS 7..."
sudo sh ${JBOSS_HOME}/bin/standalone.sh $AS7_OPTS
sleep 2
echo "done & started"
}

stop() {
echo "Stopping JBoss AS 7..."
sudo sh ${JBOSS_HOME}/bin/jboss-cli.sh --connect command=:shutdown
echo "done & stopped"
}

log() {
echo "Showing server.log..."
tail -1000f ${JBOSS_HOME}/standalone/log/server.log
}

case "$1" in
start)
start
;;
stop)
stop
;;
restart)
stop
start
;;
log)
log
;;
*)
echo $"Usage: /etc/init.d/jboss {start|stop|restart|log}"
exit
esac' >> /etc/init.d/jboss
sudo chmod 755 /etc/init.d/jboss
sudo update-rc.d jboss defaults
sudo service jboss start
