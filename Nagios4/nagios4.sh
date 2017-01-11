# Installing LAMP-SERVER file and Pre-Configurations
export DEBIAN_FRONTEND="noninteractive"
sudo apt-get update
echo mysql-server-5.7 mysql-server/root_password password pass | debconf-set-selections
echo mysql-server-5.7 mysql-server/root_password_again password pass | debconf-set-selections
sudo apt-get install lamp-server^ -y
sudo apt-get install -y build-essential libgd2-xpm-dev openssl libssl-dev xinetd apache2-utils zip unzip
touch /var/www/html/phpinfo.php
echo -e "<?php\nphpinfo();\n?>" > /var/www/html/phpinfo.php
# Create User and Group for nagios
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagios www-data
sudo usermod -a -G nagcmd www-data
# Install Nagios Core
sudo wget -q https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.4.tar.gz
sudo mkdir /home/ubuntu/nagios-4.2.4
sudo tar xzvf nagios-4.2.4.tar.gz -C /home/ubuntu/nagios-4.2.4 --strip-components=1
cd /home/ubuntu/nagios-4.2.4
./configure --with-nagios-group=nagios --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode
sudo /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
make install-webconf
# Install Nagios Plugins
sudo wget -q https://nagios-plugins.org/download/nagios-plugins-2.1.4.tar.gz
sudo mkdir /home/ubuntu/nagios-plugins-2.1.4
sudo tar xzvf nagios-plugins-2.1.4.tar.gz -C /home/ubuntu/nagios-plugins-2.1.4 --strip-components=1
cd /home/ubuntu/nagios-plugins-2.1.4
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
sudo make install
# Install and Configure NRPE
sudo wget -q https://github.com/NagiosEnterprises/nrpe/archive/3.0.1.tar.gz
sudo mkdir /home/ubuntu/nrpe-3.0.1
sudo tar xzvf 3.0.1.tar.gz -C /home/ubuntu/nrpe-3.0.1 --strip-components=1
cd /home/ubuntu/nrpe-3.0.1
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
sudo make install
sudo make install-inetd
sudo make install-config
sed -i -e '/127.0.0.1/{ s/.*/    only_from       = 127.0.0.1 192.168.33.20/ }' /etc/xinetd.d/nrpe
sudo service xinetd restart
# Configuring Nagios
sed -i '/\/servers/s/^#//' /usr/local/nagios/etc/nagios.cfg
sudo mkdir /usr/local/nagios/etc/servers
sed -i 's/nagios@localhost/devopsrajpalla@gmail.com/g' /usr/local/nagios/etc/objects/contacts.cfg
echo -e 'define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}' >> /usr/local/nagios/etc/objects/commands.cfg
# Configure Apache
sudo a2enmod rewrite
sudo a2enmod cgi
sudo htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
sudo ln -sf /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/
echo -e '[Unit]
Description=Nagios
BindTo=network.target


[Install]
WantedBy=multi-user.target

[Service]
User=nagios
Group=nagios
Type=simple
ExecStart=/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg' >> /etc/systemd/system/nagios.service
sudo systemctl enable /etc/systemd/system/nagios.service
sudo systemctl start nagios
sudo systemctl restart nagios
sudo systemctl restart apache2
sudo ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios
echo -e ' 
define host {
        use                             linux-server
        host_name                       NagiosHostServer
        alias                           My nagios host server
        address                         192.168.33.30
        max_check_attempts              5
        check_period                    24x7
        notification_interval           30
        notification_period             24x7
}

define service {
        use                             generic-service
        host_name                       NagiosHostServer
        service_description             PING
        check_command                   check_ping!100.0,20%!500.0,60%
}

define service {
        use                             generic-service
        host_name                       NagiosHostServer
        service_description             SSH
        check_command                   check_ssh
        notifications_enabled           0
}

define service {
      host_name                       NagiosHostServer
      service_description             Local Disk
      check_command                   check_local_disk!20%!10%!/
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}' > /usr/local/nagios/etc/servers/NagiosHostServer.cfg
sudo systemctl restart nagios



