echo 'ubuntu:ubuntu' | chpasswd
sudo apt-get update
sudo apt-get install -y tree unzip nginx apache2-utils php-fpm

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

# Installing Elastic Search and Its Configuration
sudo echo '
export JAVA_HOME="/opt/jdk/jdk1.8.0_112"
export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
sudo wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.2.0.deb
sudo dpkg -i elasticsearch-5.2.0.deb
sed -i -e 's,#node.name: node-1,node.name: "my first node",g' /etc/elasticsearch/elasticsearch.yml
sed -i -e 's,#cluster.name: my-application,cluster.name: mycluster1,g' /etc/elasticsearch/elasticsearch.yml
sed -i -e 's,#network.host: 192.168.0.1,network.host: 0.0.0.0,g' /etc/elasticsearch/elasticsearch.yml
sed -i -e 's,#http.port: 9200,http.port: 9200,g' /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl status elasticsearch

# Installing Kibana and its congfiguration
sudo wget -q https://artifacts.elastic.co/downloads/kibana/kibana-5.2.0-amd64.deb
sudo dpkg -i kibana-5.2.0-amd64.deb
sed -i -e 's,#server.port: 5601,server.port: 5601,g' /etc/kibana/kibana.yml
sed -i -e 's,#server.host: "localhost",server.host: "localhost",g' /etc/kibana/kibana.yml
sed -i -e 's,#elasticsearch.url: "http://localhost:9200",elasticsearch_url: "http://localhost:9200",g' /etc/kibana/kibana.yml
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana
sudo systemctl status kibana

# Configuring Nignx for reverse proxy
#sudo echo "kibanaadmin:`openssl passwd -apr1 =kibana`" | sudo tee -a /etc/nginx/htpasswd.users
sed -i -e 's/;listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 127.0.0.1,192.168.33.44/g' /etc/php/7.0/fpm/pool.d/www.conf
sudo systemctl restart php7.0-fpm
sudo htpasswd -bc /etc/nginx/htpasswd.users kibanaadmin kibanaadmin
sudo echo '
server  {
  listen 80;

  server_name 192.168.33.44;

  auth_basic "Restricted Access";
  auth_basic_user_file /etc/nginx/htpasswd.users;

  location / {
    proxy_pass http://localhost:5601;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;        
  }
}' >/etc/nginx/sites-available/default
sudo systemctl restart nginx

# Installing logstash and its Configuration
sudo wget -q https://artifacts.elastic.co/downloads/logstash/logstash-5.2.0.deb
sudo dpkg -i logstash-5.2.0.deb
sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private
sed -i -e '/\[ v3_ca \]/a subjectAltName = IP: 192.168.33.44' /etc/ssl/openssl.cnf
cd /etc/pki/tls
sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
sudo echo '    
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate_authorities => ["/etc/pki/tls/certs/logstash-forwarder.crt"]
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
    ssl_verify_mode => "force_peer"
  }
}' > /etc/logstash/conf.d/02-beats-input.conf
sudo echo '   
filter {
      if [type] == "syslog" {
        grok {
          match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
          add_field => [ "received_at", "%{@timestamp}" ]
          add_field => [ "received_from", "%{host}" ]
        }
        syslog_pri { }
        date {
          match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
  }
 }
}' > /etc/logstash/conf.d/10-syslog-filter.conf
sudo echo '
    output {
      elasticsearch {
        hosts => ["localhost:9200"]
        sniffing => true
        manage_template => false
        index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
        document_type => "%{[@metadata][type]}"
  }
}' > /etc/logstash/conf.d/30-elasticsearch-output.conf
sudo /usr/share/logstash/bin/logstash -t --path.settings /etc/logstash -f /etc/logstash/conf.d/
sudo echo '
input {
  stdin {
      type => "syslog"
    }
}
output {
  stdout {codec => rubydebug }
   elasticsearch {
          hosts => "localhost:9200"
       }
}' > /etc/logstash/conf.d/10-syslog.conf
#sudo cat /var/log/syslog | /usr/share/logstash/bin/logstash -t --path.settings /etc/logstash -f /etc/logstash/conf.d/10-syslog.conf
sudo systemctl enable logstash
sudo systemctl restart logstash
sudo systemctl status logstash

# Loading Kibana Dashboards
sudo wget -q -O /home/ubuntu/beats-dashboards-1.3.0.zip https://download.elastic.co/beats/dashboards/beats-dashboards-1.3.0.zip
cd /home/ubuntu
unzip beats-dashboards-*.zip
cd /home/ubuntu/beats-dashboards-1.3.0
sudo sh /home/ubuntu/beats-dashboards-1.3.0/load.sh
sudo wget -q -O /home/ubuntu/filebeat-index-template.json https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json
cd /home/ubuntu
sudo curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json
sudo cat /var/log/syslog | /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/10-syslog.conf