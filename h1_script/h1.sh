#!/bin/sh
cd

echo "Liberando o Yum para instalar pacotes"
cp -r /etc/yum.repos.d/ /etc/yum.repos.d.default
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo "Instalando o haproxy"
yum install haproxy -y

echo "Modificando o endereçamento IP da máquina"
nmcli connection modify enp0s3 ipv4.method manual ipv4.addresses "192.168.10.1/24"
nmcli connection up id enp0s3
nmcli general hostname h1.diorio.corp.br

echo "Fazendo backup do arquivo haproxy.cfg e trocando para o novo arquivo já configurado"
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.default.cfg
cat ./haproxy.cfg > /etc/haproxy/haproxy.cfg
# mv ./haproxy.cfg /etc/haproxy/

echo "Iniciando e habilitando o haproxy"
systemctl start haproxy
systemctl enable haproxy

echo "Liberando o acesso à porta do servidor HTTP no firewall"
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo "Modificando o arquivo SELINUX para disabled e rebootando a máquina"
cat ./config > /etc/selinux/config

echo "Script executado com sucesso!"

echo "Rebooting..."
reboot

