#!/bin/bash

# Set and create relevant folders
oniondaofolder="$HOME/.oniondao"
binfolder=/usr/local/sbin
rm -rf "$oniondaofolder"
mkdir -p "$oniondaofolder"

# Write OnionDAO function as executable
echo -e "\nCloning OnionDAO repository to $oniondaofolder"
git clone --depth 1 https://github.com/Onion-DAO/tornode.git "$oniondaofolder" &> /dev/null
echo "Writing executable to $binfolder/oniondao"
sudo cp $oniondaofolder/oniondao.sh $binfolder/oniondao
sudo chmod 755 $binfolder/oniondao
sudo chmod u+x $binfolder/oniondao

# Remove tempfiles
echo -e "\n🎉 OnionDAO installed. Type \"oniondao\" for instructions."

# Run installation of OnionDAO node
sudo bash "$oniondaofolder/install-tornode.sh"
