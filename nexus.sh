#!/bin/bash
sudo apt update
sudo apt install openjdk-8-jdk -y
cd /opt/
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo tar -zxvf latest-unix.tar.gz
sudo mv /opt/nexus-* /opt/nexus
sudo adduser nexus
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work
sudo echo 'run_as_user="nexus"' > nexus/bin/nexus.rc
cd ~
cat <<EOT>> /etc/systemd/system/nexus.service
[Unit]                                                                          
Description=nexus service                                                       
After=network.target                                                            
                                                                  
[Service]                                                                       
Type=forking                                                                    
LimitNOFILE=65536                                                               
ExecStart=/opt/nexus/bin/nexus start                                  
ExecStop=/opt/nexus/bin/nexus stop                                   
User=nexus                                                                      
Restart=on-abort                                                                
                                                                  
[Install]                                                                       
WantedBy=multi-user.target                                                      

EOT

systemctl daemon-reload
systemctl start nexus
systemctl enable nexus