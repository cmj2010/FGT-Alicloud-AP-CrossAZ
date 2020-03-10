Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
set hostname ${fgt1_id}
set admintimeout 30
end

config router static
edit 1
set gateway ${public_subnet_1_router}
set device port1
next
edit 2
set dst ${vpc_cidr}
set gateway ${private_subnet_1_router}
set device port2
next
end


config system interface
edit "port1"
set mode static
set ip ${fgt1_port1_ip} 255.255.255.0
set allowaccess ping https ssh fgfm
next
edit "port2"
set mode static
set ip ${fgt1_port2_ip} 255.255.255.0
set allowaccess ping https ssh fgfm
next
edit "port3"
set mode static
set ip ${fgt1_port3_ip} 255.255.255.0
set allowaccess ping
next
edit "port4"
set mode static
set ip ${fgt1_port4_ip} 255.255.255.0
set allowaccess ping https ssh fgfm
next
end

config system ha
set group-name "ha"
set mode a-p
set hbdev "port3" 0
set ha-mgmt-status enable
config ha-mgmt-interfaces
edit 1
set interface "port4"
set gateway ${mgmt_subnet_1_router}
next
end
set override disable
set priority 200
set unicast-hb enable
set unicast-hb-peerip ${fgt2_port3_ip}
end


config firewall policy
edit 1
set name "vpc-internet_access"
set srcintf "port2"
set dstintf "port1"
set srcaddr "all"
set dstaddr "all"
set action accept
set schedule "always"
set service "ALL"
set utm-status enable
set logtraffic all
set av-profile "default"
set webfilter-profile "default"
set ips-sensor "default"
set application-list "default"
set ssl-ssh-profile "certificate-inspection"
set nat enable
next
end




--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${fgt1_byol_license}

--===============0086047718136476635==--