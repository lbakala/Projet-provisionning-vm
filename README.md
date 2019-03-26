# Projet-provisionning-vm

Industralisation de la création des machines virtuelles via esxi avec powercli et bash
  
Il s'agit d'automatiser la création des VMS avec un minimum d'information depuis le shell comme ceci :
  
        $ sudo bash Create-VM disques os.hostname partitions cpu+ram ip
       
Ansible et Co. permettent de provionner les VMS dans un esxi géré depuis un vcenter installé sur un système windows server.

Notre objectif est de produire des machines virtuelles comme dans la restauration rapide ou si on veut comme docker.

## 1 - Environnement

  2 - hôtes esxi vsphère hyperviseur 6.5
  
  1 - Une Machine Controller - Debian9
  
  1 - Template Centos7 
  
  1 - Template Debian9
  
  1 - Template Debian8
  
  1 - Template OpenSuse15
  
  1 - Template Oracle Entreprise Linux 7
  
  1 - Template Arch Linux
  
  ## 2 - Configuration de la Machine Controller 
    
  Une Machine Linux avec powershell core + Module PowerCLI
     
  ## 3 -  Configuration des Templates
  
  Ce sont des machines à partir des quelles nos demandes seront réalisées.
    
  >**Disque disque** : 6 Giga => /boot : 500 M; LVM-PV : 5,5 Giga ; /root : 4,5;  swap : 1024 M
    
      [user@localhost ~]$ sudo lsblk
      NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
      sda               8:0    0    6G  0 disk
      ├─sda1            8:1    0  476M  0 part /boot
      └─sda2            8:2    0  5,5G  0 part
        ├─centos-root 253:0    0  4,5G  0 lvm  /
        └─centos-swap 253:1    0    1G  0 lvm  [SWAP]
      sr0              11:0    1 1024M  0 rom
      
   >**Parted**  :  la version 3.2 prend en charge le redimmentionnement à chaud en ligne de commande.
   
   version présente par défaut sur Debian9; sur Centos7 il faut désinstaller parted 3.1
   et compiler la 3.2 depuis les sources.
   
   
     [user@localhost ~]$ sudo yum remove parted
     [user@localhost ~]$ sudo yum install epel-release -y
     [user@localhost ~]$ sudo yum install gcc libuuid-devel device-mapper-devel ncurses rakudo-Readline bc -y
     [user@localhost ~]$ cd /home/user
     [user@localhost ~]$ curl -O https://ftp.gnu.org/gnu/parted/parted-3.2.tar.xz
     [user@localhost ~]$ tar -xvf parted-3.2.tar.xz
     [user@localhost ~]$ rm -fr parted-3.2.tar.xz
     [user@localhost ~]$ cd parted-3.2
     [user@localhost ~]$ sudo ./configure --prefix=/usr
     [user@localhost ~]$ sudo make
     [user@localhost ~]$ sudo make install
     [user@localhost ~]$ sudo ldconfig
     [user@localhost ~]$ sudo parted --version

  >**Installer** la clé public de la machine controller sur toutes les templates
      
      [user@controller ~]$ sudo ssh-keygen -t rsa -b 4096
      [user@controller ~]# sudo for i in ip_template1  ip_template2 ip_template3 ... 
      >do
      >ssh-copy-id -i $i
      >done
      
  >**Installer** les open-vm-tools
  
## 3 - Exemples de demandes de création de machines virtuelles

  >**Mise en place d'un serveur ftp**
  
    Os : Debian9, 2 disques 
    system : 20G { / :10G, Swap : 4096M } 
    data : 250G { /var/lib/ftp : 200G, /var/log/vsftpd : 10G, /home : ~ 40 }
    
  >**Mise en place d'un serveur oracle database**
  
    Os: Oracle Entreprise Linux 7.6, 3 disques
    system : 20G { / :10G, Swap : 8Go }
    data : 190 { 
    /u01/app/oracle/data : 135G, 
    /u01/app/oracle/log : 5G, 
    /u01/app/oracle/arch : 25G, 
    /u01/app/oracle/product : 25G 
    }
    backup : 300G {/backup: 300G } 
       
## 4 - Comment repondre à ses demandes en moins de 5 minuntes ?


    
  
  
      
