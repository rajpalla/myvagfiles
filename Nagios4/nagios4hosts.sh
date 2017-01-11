sudo apt-get update
sudo apt-get install -y nagios-plugins nagios-nrpe-server
sed -i -e '/#server_address/{ s/.*/server_address=127.0.0.1,192.168.33.30/ }' /etc/nagios/nrpe.cfg
sed -i -e '/allowed_hosts/{ s/.*/allowed_hosts=127.0.0.1,192.168.33.20/ }' /etc/nagios/nrpe.cfg
sed -i -e 's|/dev/hda1|/dev/sda1|g' /etc/nagios/nrpe.cfg
sudo systemctl restart nagios-nrpe-server
