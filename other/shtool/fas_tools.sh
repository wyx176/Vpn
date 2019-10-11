#!/bin/bash
#校园网shell脚本工具



clear;

echo "*********************************************************"
echo "           欢迎使用FAS校园网工具                 "
echo "           官网地址：wf.smwlm.com                  "
echo "*********************************************************"
echo

echo "1、iptables 开启多端口 TCP/UDP"
echo "2、重置防火墙(已提前加入校园网UDP端口)"
echo "3、修复Apache+PHP(解决后台打开出现索引目录的问题)"
echo "8、退出脚本"
echo
read -p "请选择: " Option







	
	
	if [[ $Option == 1 ]];then
	clear
	echo -e "请选择协议类型（本程序仅适用于Openvpn流控）："
	echo -e "1. TCP 代理端口"
	echo -e "2. UDP 直连端口（将转发至53端口）"
	read install_type

	echo -n "请输入端口号(0-65535):"
	read port


	if [ $install_type == 1 ];then
		/root/res/proxy.bin -l $port -d
		read has < <(cat /etc/sysconfig/iptables | grep "tcp \-\-dport $port \-j ACCEPT" )
		if [ -z "$has" ];then
			iptables -A INPUT -p tcp -m tcp --dport $port -j ACCEPT
			service iptables save
			echo -e "[添加tcp $port 至防火墙白名单]"
		fi
		read has2 < <(cat /root/res/portlist.conf | grep "port $port tcp" )
		if [ -z "$has2" ];then
			echo -e "port $port tcp">>/root/res/portlist.conf
		fi
		echo -e "[已经成功添加代理端口]"
	else
		read has < <(cat /etc/sysconfig/iptables | grep "udp \-\-dport $port \-j ACCEPT" )
		if [ -z "$has" ];then
			iptables -A INPUT -p udp -m udp --dport $port -j ACCEPT
			service iptables save
			echo -e "[添加tcp $port 至防火墙白名单]"
		fi
		iptables -t nat -A PREROUTING -p udp --dport $port -j REDIRECT --to-ports 53 && service iptables save
		echo -e "[已将此端口转发至53 UDP端口]"
	fi
	echo "感谢使用 再见！"
	exit 0
	fi
	if [[ $Option == 2 ]];then
	cd /root 
	echo
	read -p "请输入您当前后台端口: " Apache_Port
	if [ -z "$Apache_Port" ];then
	Apache_Port=
	fi 
	echo && echo "正在重置中，请稍等."
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -t nat -P PREROUTING ACCEPT
	iptables -t nat -P POSTROUTING ACCEPT
	iptables -t nat -P OUTPUT ACCEPT
	iptables -F
	iptables -t nat -F
	iptables -X
	iptables -t nat -X
	service iptables save >/dev/null 2>&1
	systemctl restart iptables.service >/dev/null 2>&1
	iptables -A INPUT -s 127.0.0.1/32  -j ACCEPT
	iptables -A INPUT -d 127.0.0.1/32  -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport ${Apache_Port} -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
	#校园网 tcp53端口
	iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT

	iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 8081 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 440 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 3389 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1194 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1195 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1196 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 1197 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 138 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 137 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 137 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 138 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 67 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 68 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 69 -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 161 -j ACCEPT
    iptables -A INPUT -p udp -m udp --dport 1194 -j ACCEPT
	iptables -A INPUT -p udp -m udp --dport 5353 -j ACCEPT
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -t nat -A PREROUTING -p udp --dport 138 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 137 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 1194 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 1195 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 1196 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 1197 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING --dst 10.8.0.1 -p udp --dport 53 -j DNAT --to-destination 10.8.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.9.0.1 -p udp --dport 53 -j DNAT --to-destination 10.9.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.10.0.1 -p udp --dport 53 -j DNAT --to-destination 10.10.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.11.0.1 -p udp --dport 53 -j DNAT --to-destination 10.11.0.1:5353
	iptables -t nat -A PREROUTING --dst 10.12.0.1 -p udp --dport 53 -j DNAT --to-destination 10.12.0.1:5353
	iptables -A INPUT -p udp -m udp --dport 5353 -j ACCEPT
	iptables -P INPUT DROP
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o eth0 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.11.0.0/24 -o eth0 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.12.0.0/24 -o eth0 -j MASQUERADE
	#iptables -t nat -A POSTROUTING -s 10.0.0.0/24  -j MASQUERADE
	iptables -t nat -A POSTROUTING -j MASQUERADE
	#允许ping
	iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
	#开放校园网端口转发
	iptables -t nat -A PREROUTING -p udp --dport 67 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 68 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 69 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p udp --dport 161 -j REDIRECT --to-ports 53
	iptables -t nat -A PREROUTING -p tcp --dport 8081 -j REDIRECT --to-ports 8080
	
	service iptables save >/dev/null 2>&1
	systemctl restart iptables.service >/dev/null 2>&1
	if [[ $? -eq 0 ]];then
	echo && echo "防火墙已重置完成"
	rm -f /root/fas_tools.sh
	else
    echo && echo "警告！iptables重启失败！请联系作者处理！"
	exit
	fi
	exit;0
	fi
	
	
	if [[ $Option == 3 ]];then
	sleep 2
	echo && echo "请稍等."
	sleep 2
	cd /root 
	if [ ! -f /bin/app ]; then
		sleep 2
		echo "您尚未安装FAS流控 ，无法执行此程序！"
		exit;0
	fi
	
	/bin/app
	
	exit;0
	fi
	

	if [[ $Option == 7 ]];then
	sleep 2
	cd /root 
	echo "正在修复中，请耐心等待！（预计10分钟内完成！）"
	sleep 5
	yum -y install epel-release
	rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
	yum -y install php70w php70w-bcmath php70w-cli php70w-common php70w-dba php70w-devel php70w-embedded php70w-enchant php70w-gd php70w-imap php70w-ldap php70w-mbstring php70w-mcrypt php70w-mysqlnd php70w-odbc php70w-opcache php70w-pdo php70w-pdo_dblib php70w-pear.noarch php70w-pecl-apcu php70w-pecl-apcu-devel php70w-pecl-imagick php70w-pecl-imagick-devel php70w-pecl-mongodb php70w-pecl-redis php70w-pecl-xdebug php70w-pgsql php70w-xml php70w-xmlrpc php70w-intl php70w-mcrypt --nogpgcheck php-fedora-autoloader php-php-gettext php-tcpdf php-tcpdf-dejavu-sans-fonts php70w-tidy --skip-broken
	systemctl restart httpd.service
	echo "修复已完成，请打开后台查看是否正常！"
	exit;0
	fi
	
	
	if [[ $Option == 8 ]];then
		echo "感谢您的使用，再见！"
		exit;0
	fi
	
	
	echo -e "\033[31m输入错误！请重新运行脚本！\033[0m "
	exit;0