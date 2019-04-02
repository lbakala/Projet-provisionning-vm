# Projet-provisionning-vm

Industrialisation de la création des machines virtuelles via esxi avec powercli et bash
  
Il s'agit d'automatiser la création des VMS avec un minimum d'information depuis le shell comme ceci :
  
        $ sudo bash Create-VM disques os.hostname partitions cpu+ram ip
       
Ansible et Co. permettent de provisionner les VMS dans un esxi géré depuis un vcenter installé sur un système windows server.

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
  
  Les fichiers ci dessous seront utilisés pour les credentials et les caractéristiques de la vm. 
  
      $ sudo ls -l /root/.vmware
        ---------- 1 root root 243 Mar 23 13:10 co.xml
        ---------- 1 root root 788 Mar 28 02:38 route.xml
        
   >**/root/.vmware/co.xml**
   
         <?xml version="1.0" encoding="iso-8859-1"?>
         <data>
         <server>
         <ip>192.xx.xx.xx</ip>
         <user>root</user>
         <pwd>******</pwd>
         </server>
         <server>
         <ip>192.xx.xx.xx</ip>
         <user>root</user>
         <pwd>*********</pwd>
         </server>
         </data>
         
  >**/root/.vmware/route.xml**
   
         <?xml version="1.0" encoding="iso-8859-1"?>
         <data>
         <image>
           <nom>Debian9</nom>
           <guestid>debian9_64Guest</guestid>
           <template>Debian9mdl</template>
           <boot>bios</boot>
         </image>
         <image>
           <nom>Centos7</nom>
           <guestid>Centos7_64Guest</guestid>
           <template>Centos7mdl1</template>
           <boot>bios</boot>
         </image>
         <image>
           <nom>Opensuse15</nom>
           <guestid>opensuse64Guest</guestid>
           <template>Opensuse15mdl11</template>
           <boot>efi</boot>
         </image>
         <size>
           <type name="small" memory="1" cpu="1" disk="8" />
           <type name="meduim" memory="2" cpu="1" disk="8" />
           <type name="large" memory="2" cpu="2" disk="8" />
           <type name="x-large" memory="4" cpu="2" disk="8" />
           <type name="xxl" memory="8" cpu="2" disk="8" />
         </size>
         </data>  
     
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
      
  >**Installer** les open-vm-tools et bc
  
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
       
## 4 - Comment repondre à ses demandes en moins de 5 minutes ?

  **Démarche manuelle**
  
  Pour repondre à cette demande à la mano (saisie des commandes ligne par ligne)
  
  - Création d'une nouvelle machine virtuelle via vsphère web client ou powercli
  - Suppression du disque de la nouvelle machine
  - Copie du disque du template concerné(version OS) dans le dossier de la nouvelle vm
  - Rattachement du nouveau disque copié à la nouvelle vm
  - Agrandissement du disque système en fonction de la taille attendu selon la demande
  - Ajout des autres disques 
  - Démarrage du système
  - Mise à jour de la taille du disque système
  - Modification des partions existantes ( agrandissement de / et swap)
  - Création des nouveaux volumes
  
  **Démarche semi-manuelle**
   
  Toutes les opérations après le rédémarrage de la machine virtuelle seront effectuées par un script
  
      [user@controller ~]# ssh serveurftp 'bash -s' < partitionner 20,250 \
                         root,xfs,10:swap,swap,4-/var/lib/ftp,xfs,200:/var/log/vsftpd,xfs,10:/home,xfs,40
        
 **Démarche d'automatisation**
 
 Toutes les opérations : création de la machine et modifications des disques
 
 sont éffectuées par des scripts
 
 Enregistrer avant tout le fichier Create-VM.psm1 dans : /opt/microsoft/powershell/6/Modules/Create-VM
 
      PS /home/user/projet/vm> Import-Module Create-VM
      
      PS /home/user/projet/vm> Get-Module -ListAvailable

Créer le fichier Create-VM avec ces lignes :
 
      #!/bin/bash
      disque=$1
      os=$2
      patitions=$3
      size=$4
      server=$5
      key="$(openssl rand -base64 32)"
      key="$(echo $key | tr -d [/+=' '])"
      disques=$(echo $disque | tr ',' '.' )

      pwsh -Command Create-VM $disques $os $key $size $server

      adr="$(awk -v var=$key -F ':' '$1==var { print $2}' /home/user/op/pzK5HdpIxXTnB2Ml)"
      machine=${os##*.}
      sed -i "/"$adr"/d"  /home/user/op/pzK5HdpIxXTnB2Ml
      ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $adr 'hostnamectl set-hostname' $machine
      ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $adr 'bash -s' < /home/user/partitionner $disque $partition
 
 ## 5 - Creation des machines virtuelles
 
         [user@controller ~]$ sudo bash Create-VM 20,250 Centos7.serveurftp \
         >root,xfs,10:swap,swap,4-/var/lib/ftp,xfs,200:/var/log/vsftpd,xfs,10:/home,xfs,40 large 102.xx.xx.xx
         
         [user@controller ~]$ sudo bash Create-VM 20,190,300 Oracle7.svrdb3046prd \
         >root,xfs,20:swap,swap,8-\
         >u01/app/oracle/data,xfs,135:\
         >u01/app/oracle/log,xfs,5:\ 
         >u01/app/oracle/arch:xfs,25G:\ 
         >u01/app/oracle/product,xfs,25-\
         >backup,xfs,300 large 102.xx.xx.xx
         
## 6 - Test de réalisation

       $ pwsh
       PS /home/user> Create-VM 20.190.300 Centos7.svrdb3046prd xzyterdfge large 192.168.0.26
       CapacityGB      Persistence   Filename    
       ----------      ----------    --------                
       20,000          Persistent    [datastore1] svrdb3046prd/Centos7mdl1.vmdk
       190,000         Persistent    [datastore1] svrdb3046prd/svrdb3046prd.vmdk
       300,000         Persistent    [datastore1] svrdb3046prd/svrdb3046prd_1.vmdk 
       xzyterdfge:192.168.x.xx
       192.168.x.xx
       
 - Connexion à la machinne  
 
       PS /home/user> ssh 192.168.x.xx
       [root@localhost ~]# lsblk
       NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
       sda               8:0    0   20G  0 disk
       ├─sda1            8:1    0  476M  0 part /boot
       └─sda2            8:2    0  5,5G  0 part
         ├─centos-root 253:0    0  4,5G  0 lvm  /
         └─centos-swap 253:1    0    1G  0 lvm  [SWAP]
       sdb               8:16   0  190G  0 disk
       sdc               8:32   0  300G  0 disk
       sr0              11:0    1 1024M  0 rom
       
 - Vérification des point de montages  
 
        [root@localhost ~]# df -h
        Sys. de fichiers        Taille Utilisé Dispo Uti% Monté sur
        /dev/mapper/centos-root   4,6G    1,3G  3,3G  29% /
        devtmpfs                  909M       0  909M   0% /dev
        tmpfs                     920M       0  920M   0% /dev/shm
        tmpfs                     920M    8,5M  912M   1% /run
        tmpfs                     920M       0  920M   0% /sys/fs/cgroup
        /dev/sda1                 473M    135M  339M  29% /boot
        tmpfs                     184M       0  184M   0% /run/user/0
 
 - Vérification de la taille du disque et des partions du premier disque
 
       [root@localhost ~]# fdisk /dev/sda -l
       Disque /dev/sda : 21.5 Go, 21474836480 octets, 41943040 secteurs
       Unités = secteur de 1 × 512 = 512 octets
       Taille de secteur (logique / physique) : 512 octets / 512 octets
       taille d'E/S (minimale / optimale) : 512 octets / 512 octets
       Type d'étiquette de disque : dos
       Identifiant de disque : 0x0001b03d
      
       Périphérique Amorçage  Début         Fin      Blocs    Id. Système
       /dev/sda1   *        2048      976895      487424   83  Linux
       /dev/sda2          976896    12582911     5803008   8e  Linux LVM
       [root@localhost ~]#
      
 - Vérification de groupes de volumes présents
 
       [root@localhost ~]# vgs
       VG     #PV #LV #SN Attr   VSize VFree
       centos   1   2   0 wz--n- 5,53g    0
     
- Patitionnement de la machine
      
      # ssh 192.168.x.xx 'bash -s' < partitionner 20,190,300 root,xfs,10:swap,swap,8-\
      >u01/app/oracle/data,xfs,135:\
      >u01/app/oracle/log,xfs,5:\
      >u01/app/oracle/arch:xfs,25:\
      >u01/app/oracle/product,xfs,24-\
      >backup,xfs,299 
      
- Vérification des points de montages

      [root@localhost ~]# df -h
      Sys. de fichiers                    Taille Utilisé Dispo Uti% Monté sur
      /dev/mapper/centos-root                10G    1,3G  8,8G  13% /
      devtmpfs                              909M       0  909M   0% /dev
      tmpfs                                 920M       0  920M   0% /dev/shm
      tmpfs                                 920M    8,5M  912M   1% /run
      tmpfs                                 920M       0  920M   0% /sys/fs/cgroup
      /dev/sda1                             473M    135M  339M  29% /boot
      /dev/mapper/vg1-u01apporacledata      135G     33M  135G   1% /u01/app/oracle/data
      /dev/mapper/vg1-u01apporaclelog       5,0G     33M  5,0G   1% /u01/app/oracle/log
      /dev/mapper/vg1-u01apporacleproduct    24G     33M   24G   1% /u01/app/oracle/product
      /dev/mapper/vg2-backup                299G     33M  299G   1% /backup
      tmpfs                                 184M       0  184M   0% /run/user/0

**Temps de réalisation en deux temps : 3m22s**

**Temps de réalisation avec un script de bout en bout : 2m11s**
