#!/bin/bash
wget http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
rpm -ivh nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum -y install nginx
systemctl start nginx
systemctl enable nginx
systemctl status nginx.service
wget https://ecs-instance-driver.obs.cn-north-1.myhuaweicloud.com/datadisk/LinuxVMDataDiskAutoInitialize.sh
chmod +x LinuxVMDataDiskAutoInitialize.sh
yum -y install expect
/usr/bin/expect <<EOF
spawn sh ./LinuxVMDataDiskAutoInitialize.sh
expect "Step 3: Please choose the dis(e.g: /dev/vdb and q to quit):"
send "/dev/vdb\n"
expect "Please enter a location to mount (e.g: /mnt/data):"
send "/data_disk\n"
expect eof
EOF
wget -P /data_disk https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/build-a-personal-website-based-on-wordpress/open-source-software/mysql-5.7.31-1.el7.x86_64.rpm-bundle.tar
tar -xvf /data_disk/mysql-5.7.31-1.el7.x86_64.rpm-bundle.tar -C /data_disk
yum -y install libaio perl-JSON && yum remove -y mysql-libs
rpm -ivh /data_disk/mysql-community-{server,client,common,libs,devel}-*
systemctl start mysqld
systemctl enable mysqld-
systemctl status mysqld.service
mypwd=`grep "temporary password" /var/log/mysqld.log|awk -F' ' "{print $NF}"|awk '{print $NF}'`
/usr/bin/expect <<EOF
spawn mysql_secure_installation
expect "Enter password for user root: "
send "$mypwd\r"
expect "New password:"
send "$1\r"
expect "Re-enter new password:"
send "$1\r"
expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "N\r"
expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "Y\r"
expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "Y\r"
expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "Y\r"
expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "Y\r"
expect eof
exit
EOF
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum --skip-broken -y install php70w-tidy php70w-common php70w-devel php70w-pdo php70w-mysql php70w-gd php70w-ldap php70w-mbstring php70w-mcrypt php70w-fpm
php -v
systemctl start php-fpm
systemctl enable php-fpm
sed -i "9s/index  index.html index.htm;/index index.php index.html index.htm;/" /etc/nginx/conf.d/default.conf
sed -i "10a location ~ \\\.php$ {" /etc/nginx/conf.d/default.conf
sed -i "11a root html;" /etc/nginx/conf.d/default.conf
sed -i "12a fastcgi_pass 127.0.0.1:9000;" /etc/nginx/conf.d/default.conf
sed -i "13a fastcgi_index index.php;" /etc/nginx/conf.d/default.conf
sed -i "14a fastcgi_param SCRIPT_FILENAME /usr/share/nginx/html\$fastcgi_script_name;" /etc/nginx/conf.d/default.conf
sed -i "15a include fastcgi_params;" /etc/nginx/conf.d/default.conf
sed -i "16a }" /etc/nginx/conf.d/default.conf
service nginx reload
echo "<?php" >> /usr/share/nginx/html/info.php
echo "phpinfo();" >> /usr/share/nginx/html/info.php
echo "?>" >> /usr/share/nginx/html/info.php
/usr/bin/expect <<EOF
spawn mysql -u root -p
expect "Enter password: "
send "$1\r"
expect "mysql>"
send "CREATE DATABASE wordpress;\r"
expect "mysql>"
send "GRANT ALL ON wordpress.* TO $2@localhost IDENTIFIED BY '$3';\r"
expect eof
exit
EOF
wget -P /usr/share/nginx/html/ https://documentation-samples.obs.cn-north-4.myhuaweicloud.com/solution-as-code-publicbucket/solution-as-code-moudle/build-a-personal-website-based-on-wordpress/open-source-software/wordpress-4.9.8.tar.gz
tar -xvf /usr/share/nginx/html/wordpress-4.9.8.tar.gz -C /usr/share/nginx/html/
chmod -R 777 /usr/share/nginx/html/wordpress/