#!/bin/bash

# Global config
BIN_FOLDER=/usr/local/sbin
ONIONDAO_PATH="$HOME/.oniondao/"

## ###############
## Force latest version
## ###############
cd "$ONIONDAO_PATH"
git pull &> /dev/null
sudo cp $ONIONDAO_PATH/oniondao.sh $BIN_FOLDER/oniondao
sudo chmod 755 $BIN_FOLDER/oniondao
sudo chmod u+x $BIN_FOLDER/oniondao

## ###############
## Tor POAP config
## ###############

cat << "EOF"

==========================================================

__   __ _  __  __   __ _    ____   __    __   ____ 
 /  \ (  ( \(  )/  \ (  ( \  (  _ \ /  \  / _\ (  _ \
(  O )/    / )((  O )/    /   ) __/(  O )/    \ ) __/
 \__/ \_)__)(__)\__/ \_)__)  (__)   \__/ \_/\_/(__)


==========================================================

Onion POAP is an Onion DAO initiative that hands out POAP tokens to people who run a Tor exit node.

This is a setup script that will install a Tor exit node & register that node with Tor POAP.

⚠️  Disclaimer: Tor POAP is *NOT* associated with the Tor project. To learn about the Tor project, go to: https://www.torproject.org/.

⚠️  Disclaimer: Tor POAP is *NOT* associated with POAP. To learn more about POAP, go to https://poap.xyz/.

🚨  IMPORTANT NOTICE: running a Tor exit node is legal in most places, but please check your local rules. For legal resources, refer to https://community.torproject.org/relay/community-resources/

Credits:

Setup script based on https://tor-relay.co/
Code by mentor.eth


Press any key to continue...

EOF

read

## ###############
## The below script is based
## on https://tor-relay.co/
## edits marked with 🔥
## ###############


RELEASE='focal'
IS_EXIT=true
IS_BRIDGE=false
INSTALL_NYX=true
CHECK_IPV6=true
ENABLE_AUTO_UPDATE=true
OBFS4PORT_LT_1024=true

C_RED="\e[31m"
C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_DEFAULT="\e[39m"

function echoInfo() {
  echo -e "${C_CYAN}$1${C_DEFAULT}"
}

function echoError() {
  echo -e "${C_RED}$1${C_DEFAULT}"
}

function echoSuccess() {
  echo -e "${C_GREEN}$1${C_DEFAULT}"
}

function handleError() {
  echoError "-> ERROR"
  sudo /etc/init.d/tor stop
  echoError "An error occured on the last setup step."
  echoError "If you think there is a problem with this script please share information about the error and you system configuration for debugging: tor@flxn.de"
}

## ###############
## Get needed data
## ###############

## ###############
## CHeck for old data
## ###############
if test -f /etc/tor/torrc; then
  NODE_NICKNAME=$( grep -Po "(?<=Nickname )(.*)" /etc/tor/torrc 2> /dev/null )
  NODE_BANDWIDTH=$( grep -Po "(?<=AccountingMax )(.*)(?= TB)" /etc/tor/torrc 2> /dev/null )
  OPERATOR_EMAIL=$( grep -Po "(?<=ContactInfo )(.*)" /etc/tor/torrc 2> /dev/null )
  OPERATOR_WALLET=$( grep -Po "(?<= address: )(.*)(?= -->)" /etc/tor/tor-exit-notice.html 2> /dev/null )
  OPERATOR_TWITTER=$( grep -Po "(?<=OPERATOR_TWITTER=)(.*)" "$ONIONDAO_PATH/.oniondaorc" 2> /dev/null )
  REDUCED_EXIT_POLICY=$( grep -Po "(?<=REDUCED_EXIT_POLICY=)(.*)" "$ONIONDAO_PATH/.oniondaorc" 2> /dev/null )
fi

echoInfo "\n\n----------------------------------------"
echoInfo "OnionDAO needs some information"
echoInfo "----------------------------------------\n\n"

echoError "\nNOTE: details such as Node nickname, operator email etc are obtained from /etc/tor/torrc, you may edit them there.\n\n"


# Operator email
if [ "$OPERATOR_WALLET" ]; then

  read -p "Keep $OPERATOR_WALLET as your node wallet to receive POAPs? [Y/n] " KEEP_OPERATOR_WALLET
  if [ "${KEEP_OPERATOR_WALLET,,}" = "n" ]; then
    read -p "Your wallet address or ENS (to receive POAP): " OPERATOR_WALLET
  fi

else

  read -p "Your wallet address or ENS (to receive POAP): " OPERATOR_WALLET
  
fi

# Operator twitter
if [ "$OPERATOR_TWITTER" ]; then

  read -p "Keep $OPERATOR_TWITTER as your twitter handle? [Y/n] " KEEP_OPERATOR_TWITTER
  if [ "${KEEP_OPERATOR_TWITTER,,}" = "n" ]; then
    read -p "Your twitter handle (optional): " OPERATOR_TWITTER
  fi

else

  read -p "Your twitter handle (optional): " OPERATOR_TWITTER
  
fi

# Mark unknown values
NODE_BANDWIDTH=${NODE_BANDWIDTH:-"unknown"}
NODE_NICKNAME=${NODE_NICKNAME:-"unknown"}
REDUCED_EXIT_POLICY=${REDUCED_EXIT_POLICY:-"unknown"}

echoSuccess "\n\n----------------------------------------"
echoSuccess "Check your information"
echoSuccess "----------------------------------------"
echoSuccess "POAP wallet: $OPERATOR_WALLET"
echoSuccess "Node nickname: $NODE_NICKNAME"
echoSuccess "Operator email: $OPERATOR_EMAIL"
echoSuccess "Operator twitter: $OPERATOR_TWITTER"
echoSuccess "Monthly bandwidth limit: $NODE_BANDWIDTH TB\n"
echoInfo "Press any key to continue or ctrl+c to exit..."
read

# 🔥 added a comment to the tor notice page with the POAP address so I can scrape it for distribution
echo "<!-- Onion DAO address: $OPERATOR_WALLET -->" >> /etc/tor/tor-exit-notice.html

echoInfo "------------------------------------------------------"
echoInfo "Registering node with OnionDAO..."
echoInfo "------------------------------------------------------\n"

## ###############
## Get remote IP
## ###############

# Get ipv4 of this server
REMOTE_IP=$( curl ipv4.icanhazip.com 2> /dev/null )
if [ ${#REMOTE_IP} -lt 7 ]; then
  echo "Remote ip: icanhaz unavailable, using canhaz"
  REMOTE_IP=$( curl ipv4.canhazip.com 2> /dev/null )
elif [ ${#REMOTE_IP} -lt 7 ]; then
  echo "Remote ip: canhaz unavailable, using ipify"
  REMOTE_IP=$( curl api.ipify.org 2> /dev/null )
elif [ ${#REMOTE_IP} -lt 7 ]; then
  echo "Remote ip: ipify unavailable, using seeip"
  REMOTE_IP=$( curl https://ip4.seeip.org 2> /dev/null )
fi

## ###############
## Data sanitation
## ###############

# Save data that is not in different places
echo "OPERATOR_TWITTER=$OPERATOR_TWITTER" > $ONIONDAO_PATH/.oniondaorc
echo "REDUCED_EXIT_POLICY=$REDUCED_EXIT_POLICY" >> $ONIONDAO_PATH/.oniondaorc

# Check for the (current) edge case that this is a ipv6-only server, assumption: if we could not find an ipv4, you are an ipv6
if [ ${#REMOTE_IP} -lt 7 ]; then
  echoInfo "Could not find an ipv4 address for your server, using ipv6"
  REMOTE_IP="$IPV6_ADDRESS"
fi

# Formulate post data format
post_data="{"
post_data="$post_data\"ip\": \"$REMOTE_IP\""
post_data="$post_data,\"email\": \"$OPERATOR_EMAIL\""
post_data="$post_data,\"bandwidth\": \"$NODE_BANDWIDTH\""
post_data="$post_data,\"reduced_exit_policy\": \"$REDUCED_EXIT_POLICY\""
post_data="$post_data,\"node_nickname\": \"$NODE_NICKNAME\""
post_data="$post_data,\"wallet\": \"$OPERATOR_WALLET\""

if [ ${#OPERATOR_TWITTER} -gt 3 ]; then
  post_data="$post_data,\"twitter\": \"$OPERATOR_TWITTER\""
fi

post_data="$post_data}"

# Register node with Onion DAO oracle
curl -X POST https://oniondao.web.app/api/tor_nodes \
   -H 'Content-Type: application/json' \
   -d "$post_data"

echoInfo "\n------------------------------------------------------"
echoInfo "Want to stay up to date on OnionDAO developments?"
echoInfo "------------------------------------------------------\n"
echoInfo "👉 Join us in the Rocketeer discord in the #onion-dao channel: https://discord.gg/rocketeers\n"