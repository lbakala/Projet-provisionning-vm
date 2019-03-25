# Projet-provisionning-vm
Industralisation de la création des machines virtuelles via esxi avec powercli et bash
  
Il s'agit d'automatiser la création des VMS avec minimum d'information depuis le shell
  
        bash Create-VM disques os.hostname partitions cpu+ram  ip
        
        diques : 20 pour un disque de 20 giga
                 20,50,100 pour trois diques de 20, 50 et 100 giga
                 
        os.hostname : Centos7.webserver pour une demande de création d'une vm centos7 avec webserver comme nom de la machine
        
        partitions : root,xfs,18 pour une demande de mise en place d'une partition / de 18 giga de type xfs
                     root,ext4,10 pour une demande de mise en place d'une partition / de 10 giga de type ext4
                     root,xfs,8:home,xfs,10:opt,xfs,60
                     root,xfs,10:home,xfs,10-var/lib/mysql,xfs,80 : deux disques sda (/ et home) et sdb (/var/lib/mysql)
                     
        cpu+ram : small vcpu=1, ram=1024 M
                  meduim vpu=x, ram=y
                  large vcpu=x, ra
                  x-large vcpu=x, ram=y
                  
      bash Create-VM 20 Centos7.webserver root,xfs,10 small 192.168.3.24
      
      bash Create-VM 20,50 Centos7.webserver root,xfs,10-var/lib/mysql,xfs,40:var/log/mysql,xfs,9 small 192.168.3.24 
      
      disques : sda = 20 giga, sdb = 50
                sda1 /boot ==> 500 M
                sda2 ==> LVM { LV : swap = 1024M, LV : root = 10G } on peut modifier la swap  si on veut : root,xfs,10:swap:5,swap
            
   
                sdb ==> LVM { LV: varlibmysql = 40G, LV : varlogmysql = 9G }
        
        
