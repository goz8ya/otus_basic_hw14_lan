#!/bin/bash
echo 'ip адрес:'
ip addr
echo ""
echo 'mac адрес:'
ip maddr
echo ""
echo "Шлюз по умолчанию"
ip route | grep default
echo ""
echo "Настройки DNS"
resolvectl dns


file_netplan=$(ls /etc/netplan/ | head -1)
echo "Hастройки сети из файла $file_netplan"
cat /etc/netplan/*.yaml
echo ""
echo "Находим первый сетевой интерфейс не равный lo, docker"
ls /sys/class/net | grep -vE '(docker|lo)' | head -1
int=$(ls /sys/class/net | grep -vE '(docker|lo)' | head -1)

echo ""
if [ -f /etc/netplan/$file_netplan ]
then
	        echo "файл $file_netplan существует "
	else
		        echo "файла $file_netplan нет "
			        #netplan generate
				#       file_netplan1=/etc/netplan/00-installer-config.yaml
				        echo "# netplan DHCP config" > /etc/netplan/00-installer-config.yaml
					        echo "network:" >> /etc/netplan/00-installer-config.yaml
						        echo "  ethernets:" >> /etc/netplan/00-installer-config.yaml
							        echo "    $int:" >> /etc/netplan/00-installer-config.yaml
								        echo "      dhcp4: true" >> /etc/netplan/00-installer-config.yaml
									        echo "  version: 2" >> /etc/netplan/00-installer-config.yaml
										        cat /etc/netplan/00-installer-config.yaml
fi


echo ""
echo "Назначаем ip адрес с помощью команды ip"
ip addr add 1.2.3.4/32 dev $int
echo ""
echo "Показываем настройки интерфейса #ip addr show  dev $int"
ip addr show  dev $int
echo ""
echo "hostname -I"
hostname -I
echo ""
echo "Настраиваем динамический адрес через netpland $file_netplan"
file_netplan=$(ls /etc/netplan/ | head -1)
fullfile_netplan=/etc/netplan/$file_netplan
echo "путь $fullfile_netplan"
echo "# netplan DHCP config" > $fullfile_netplan
echo "network:" >> $fullfile_netplan
echo "  ethernets:" >> $fullfile_netplan
echo "    $int:" >> $fullfile_netplan
echo "      dhcp4: true" >> $fullfile_netplan
echo "  version: 2" >> $fullfile_netplan
cat $fullfile_netplan
echo "активация DHCP"
netplan try 2>/dev/null
echo ""
echo "правим файл $fullfile_netplan"
echo "Настраиваем статический ip vs google dns"
echo "# netplan static IP config" > $fullfile_netplan
echo "network:" >> $fullfile_netplan
echo "  ethernets:" >> $fullfile_netplan
echo "    $int:" >> $fullfile_netplan
echo "      dhcp4: false" >> $fullfile_netplan
echo "      addresses: [10.192.0.70/24]" >> $fullfile_netplan
echo "      routes:" >> $fullfile_netplan
echo "        - to: default" >> $fullfile_netplan
echo "          via: 10.192.0.1" >> $fullfile_netplan
echo "      nameservers:" >> $fullfile_netplan
echo "        addresses:" >> $fullfile_netplan
echo "          - 8.8.8.8" >> $fullfile_netplan
echo "          - 8.8.4.4" >> $fullfile_netplan
echo "  version: 2" >> $fullfile_netplan
cat $fullfile_netplan
echo "статический адрес установлен применяем настройки"
netplan try 2>/dev/null
echo ""
echo "ip addr"
ip addr
echo "ip route"
ip route
echo "resolvectl dns"
resolvectl dns

echo ""
echo "правим файл $fullfile_netplan"
echo "Настраиваем статический ip vs настраиваем роутер в качестве DNS"
echo "# netplan static IP config" > $fullfile_netplan
echo "network:" >> $fullfile_netplan
echo "  ethernets:" >> $fullfile_netplan
echo "    $int:" >> $fullfile_netplan
echo "      dhcp4: false" >> $fullfile_netplan
echo "      addresses: [10.192.0.70/24]" >> $fullfile_netplan
echo "      routes:" >> $fullfile_netplan
echo "        - to: default" >> $fullfile_netplan
echo "          via: 10.192.0.1" >> $fullfile_netplan
echo "      nameservers:" >> $fullfile_netplan
echo "        addresses:" >> $fullfile_netplan
echo "          - 10.192.0.1" >> $fullfile_netplan
echo "  version: 2" >> $fullfile_netplan
cat $fullfile_netplan
echo "статический адрес установлен применяем настройки"
netplan try 2>/dev/null
echo "resolvectl dns"
resolvectl dns

echo "удаляем маршрут по умолчанию"
ip route delete default
echo "показывем маршрут и пингуем его"
ip route
ping -i 0.1 -c 5 8.8.8.8
echo ""
echo "возвращаем маршрут"
ip route add default via 10.192.0.1 dev $int
echo "показывем маршрут и пингуем его"
ip route
ping -i 0.1 -c 5 8.8.8.8

