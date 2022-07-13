#/bin/bash
cd ~
echo "****************************************************************************"
echo "*                                                                          *"
echo "*   Skywire Hypervisor & Visor v1.0.1 Setup for Raspberry Pi 0WH, 3 & 4    *"
echo "*           Include Raspberry update & Autoupdater & Autostart             *"
echo "*                                by Allo                                   *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo && echo
	## COLOR
  RED="\033[0;31m"
  STDT="\033[0m"
	#UPDATE
echo
echo -e "${RED}>>>>>>>>>> SYSTEM UPDATE${STDT}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y cron-apt
	#CONFIG CRON-APT 
echo	
echo "Configure Autoupdates: ALL AVAILABLE UDATES? [Y/N]"
read UPDATES
if [[ $UPDATES =~ "y" ]] ; then
sed -i -- 's/-d//' /etc/cron-apt/action.d/3-download
fi
	#DIR
echo
echo -e "${RED}>>>>>>>>>> CREATE FOLDER${STDT}"
echo "/etc/skywire-visor/"
echo "/tmp/bin/"
sudo mkdir -p '/etc/skywire-visor'
sudo mkdir -p '/tmp/bin'
	#DOWNLOAD
echo
echo -e "${RED}>>>>>>>>>> DOWNLOAD NEEDED FILES FROM OFFICIAL SKY GITHUB${STDT}"
sudo wget -c https://github.com/skycoin/skywire/releases/download/v1.0.1/skywire-v1.0.1-linux-amd64.tar.gz -O '/tmp/skywire.tar.gz'
	#EXTRAC
echo 
echo -e "${RED}>>>>>>>>>> EXTRACT TO TEMP${STDT}"
sudo tar xvzf '/tmp/skywire.tar.gz' -C '/tmp/bin'
sudo rm -rf /tmp/bin/*.md
	#INSTALL
echo
echo -e "${RED}>>>>>>>>>> INSTALL..${STDT}"
sudo cp -rf /tmp/bin/* '/usr/bin/'
	#HYPER
echo
echo "Do you want to install Hypervisor? [y/n]"
read HYPERINSTALL
if [[ $HYPERINSTALL =~ "y" ]] ; then
echo -e "${RED}>>>>>>>>>> INSTALL HYPERVISOR..${STDT}"
sudo /usr/bin/skywire-cli visor config gen -o /etc/skywire-config.json --is-hypervisor
echo "YOUR HYPERVISOR-PUBKEY IS:"
cat /etc/skywire-config.json | grep "pk" | awk '{print substr($2,2,66)}'
fi
	#VISOR
echo -e "${RED}>>>>>>>>>> INSTALL VISOR..${STDT}"
sudo /usr/bin/skywire-cli config gen -o /etc/skywire-config.json
echo
echo "PLEASE ENTER YOUR HYPERVISOR-PUBKEY:"
read HYPKEY
sudo sed -i 's/"hypervisors".*/"hypervisors": [ "'$HYPKEY'"],/' /etc/skywire-config.json
	#SYSTEMD
echo
echo -e "${RED}>>>>>>>>>> INSTALL AUTORUN${STDT}"
sudo wget -c https://raw.githubusercontent.com/Allohol/Skywire-Setup/main/skywire-visor.service -O /etc/systemd/system/skywire-visor.service
sudo systemctl daemon-reload
sudo systemctl enable skywire-visor.service
	#REBOOT
if [ -f /var/run/reboot-required ] 
then
echo "[*** You must reboot your machine! ***]"
fi
