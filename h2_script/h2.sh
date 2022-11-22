#!/bin/sh
cd

echo "Liberando o Yum para instalar pacotes"
cp -r /etc/yum.repos.d/ /etc/yum.repos.d.default
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo "Instalando o httpd"
yum install httpd nfs-utils -y

echo "Modificando o endereçamento IP da máquina"
nmcli connection modify enp0s3 ipv4.method manual ipv4.addresses "192.168.10.2/24"
nmcli connection up id enp0s3
nmcli general hostname h2.diorio.corp.br

echo "Iniciando o httpd"
systemctl start httpd
systemctl enable httpd

echo "Liberando o acesso à porta do servidor HTTP no firewall"
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo "Montando o diretório que irá ter acesso a pasta compartilhada"
mount -t nfs 192.168.10.4:/dados/shared /var/www/html

echo "Fazendo backup do arquivo fstab e trocando para o novo arquivo já configurado"
cp /etc/fstab /etc/fstab.default
cat ./fstab > /etc/fstab
# mv ./fstab /etc/fstab

echo "Modificando o arquivo SELINUX para disabled e rebootando a máquina"
cat ./config > /etc/selinux/config

echo "Script executado com sucesso!"

echo "Rebooting..."
reboot

