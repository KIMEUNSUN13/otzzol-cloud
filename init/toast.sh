#!/bin/bash

## Add User
usermod -G wheel centos
echo 'centos' | passwd --stdin centos
useradd -G wheel infadm
echo 'infadm' | passwd --stdin infadm

## sudo config
cp -a /etc/sudoers /etc/sudoers.bak 
echo "infadm  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers 

## sshd config
sed -i.bak "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
systemctl restart sshd

for NUM in $(seq 2 7); do
	sed -i "s/ONBOOT=yes/ONBOOT=no/g" /etc/sysconfig/network-scripts/ifcfg-eth${NUM} 
done >/dev/null 2>&1

## kernel update disable
# sed -i.bak "s/exclude=xe-guest-utilities*/exclude=xe-guest-utilities*,kernel*,centos-release*/g" /etc/yum.conf
sed -i "s/UPDATEDEFAULT=yes/UPDATEDEFAULT=no/g" /etc/sysconfig/kernel

## profile config
echo "export HISTTIMEFORMAT='%y/%m/%d %H:%M:%S '" >> /etc/profile
sed -i.bak "s/HISTSIZE=1000/HISTSIZE=100000/g"  /etc/profile
# sed -i "s/HISTFILESIZE=0//g" /etc/profile

## locale, localtime config
localectl set-locale LANG=ko_KR.utf8 
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

## Security
userdel -r adm

chmod -s /sbin/unix_chkpwd
chmod -s /usr/bin/at

touch /etc/hosts.equiv
chmod 000 /etc/hosts.equiv
touch /root/.rhosts
chmod 000 /root/.rhosts

chown root /etc/at.allow
chmod 640 /etc/at.allow
chown root /etc/at.deny
chmod 640 /etc/at.deny

chmod 4750 /bin/su
chmod 4750 /usr/bin/su

sed -i "s/TMOUT\=324000/TMOUT\=600/g" /etc/profile
echo -e "
export TMOUT" >> /etc/profile

perl -pi -e 's/^#*auth(.*)pam_wheel.so use_uid(.*)/$&\nauth            required         pam_wheel.so use_uid/ig' /etc/pam.d/su
# sed -i.bak "s/#auth required pam_wheel.so use_uid/auth required	pam_wheel.so use_uid/g" /etc/pam.d/su

echo -e "
lcredit=-1
ucredit=-1
dcredit=-1
ocredit=-1
minlen=8" >> /etc/security/pwquality.conf

#setenforce 0
#sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#systemctl disable firewalld
#systemctl stop firewalld

echo -e "
####################################################################################
#       This system is for the use of authorized users only.                       #
#       Individuals using this computer system without authority, or in            #
#       excess of their authority, are subject to having all of their              #
#       activities on this system monitored and recorded by system                 #
#       personnel.                                                                 #
#                                                                                  #
#       In the course of monitoring individuals improperly using this              #
#       system, or in the course of system maintenance, the activities             #
#       of authorized users may also be monitored.                                 #
#                                                                                  #
#       Anyone using this system expressly consents to such monitoring             #
#       and is advised that if such monitoring reveals possible                    #
#       evidence of criminal activity, system personnel may provide the            #
#       evidence of such monitoring to law enforcement officials.                  #
####################################################################################
" > /etc/issue.net
# 원격 접속 시 메시지 출력(상태 로그인 전)

echo -e "
####################################################################################
#       This system is for the use of authorized users only.                       #
#       Individuals using this computer system without authority, or in            #
#       excess of their authority, are subject to having all of their              #
#       activities on this system monitored and recorded by system                 #
#       personnel.                                                                 #
#                                                                                  #
#       In the course of monitoring individuals improperly using this              #
#       system, or in the course of system maintenance, the activities             #
#       of authorized users may also be monitored.                                 #
#                                                                                  #
#       Anyone using this system expressly consents to such monitoring             #
#       and is advised that if such monitoring reveals possible                    #
#       evidence of criminal activity, system personnel may provide the            #
#       evidence of such monitoring to law enforcement officials.                  #
####################################################################################
" > /etc/motd
# 로컬, 원격 접속 시 로그인 성공 후 메시지 출력(로그인 후)
