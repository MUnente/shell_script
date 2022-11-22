#!/bin/sh
cd

echo "Liberando o Yum para instalar pacotes"
cp -r /etc/yum.repos.d/ /etc/yum.repos.d.default
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo "Instalando o nfs-utils"
yum install nfs-utils -y

echo "Modificando o endereçamento IP da máquina"
nmcli connection modify enp0s3 ipv4.method manual ipv4.addresses "192.168.10.4/24"
nmcli connection up id enp0s3
nmcli general hostname h4.diorio.corp.br

echo "Fazendo backup do arquivo nfs.conf e trocando para o novo arquivo já configurado"
cp /etc/nfs.conf /etc/nfs.default.conf
cat ./nfs.conf > /etc/nfs.conf
# mv ./nfs.conf /etc/

echo "Iniciando e habilitando o nfs-server"
systemctl start nfs-server
systemctl enable nfs-server

echo "Criando a pasta compartilhada"
mkdir -p /dados/shared
chmod o+w /dados/shared

echo "Fazendo backup do arquivo /etc/exports e movendo o arquivo já configurado"
cp /etc/exports /etc/exports.default
cat ./exports > /etc/exports
# mv ./exports /etc/

echo "Exportando o arquivo configurado"
exportfs -r
showmount --exports 127.0.0.1

echo "Liberando o acesso à porta do servidor HTTP no firewall"
firewall-cmd --permanent --add-service=nfs
firewall-cmd --reload

echo "Criando arquivo index na pasta compartilhada"
cat <<-END >/dados/shared/index.html
<html>
<body>Test Site - $(hostname)</body>
</html>
END

# echo "Movendo arquivo index para pasta compartilhada"
# mv ./index.html /dados/shared

echo "Modificando o arquivo SELINUX para disabled e rebootando a máquina"
cat ./config > /etc/selinux/config

echo "Script executado com sucesso!"

echo "Rebooting..."
reboot

