#!/bin/bash

mainDir="$HOME/.2paco"
secretsDir="$mainDir/2fa"
logFile="$mainDir/2paco.log"
listenPort=9002
rotationTime=$((1 * 30)) # In seconds


function init () {
	if ! hash gpg 2>/dev/null ; then
        echo "Please ensure that GnuPG is installed!"
        exit
    fi
    if ! hash oathtool 2>/dev/null ; then
        echo "Please ensure that oathtool is installed!"
        exit
    fi
}

init

# Collect valid secrets in array
declare -a secrets
function checkSecrets () {
	if [ ! -d "$mainDir" ]; then
		mkdir -p "$secretsDir"
		chmod 0700 "$secretsDir"
	fi
	
	for file in `find $secretsDir -type f -printf "%f\n"`; do
		secrets[${#secrets[@]}]=$file
	done

	echo ${secrets[*]}
}

checkSecrets


function checkResources () {
	resource=$1
	if [ -d $resource ] && [ ! -d $mainDir/$resource ]; then
		mv $resource $mainDir
	elif [ -f $resource ] && [ ! -f $mainDir/$resource ]; then
		mv $resource $mainDir
	elif [ ! -d $mainDir/$resource ]; then
		if [ ! -f $mainDir/$resource ]; then
			printf "Please ensure that $resource is in the current directory or in $mainDir\nExiting...\n"
			exit
		fi
	fi
}

#checkResources "pic"
#checkResources "update-ePaper.py"


####### Copyright (c) 2018, info AT markusholtermann DOT eu ########
### https://markusholtermann.eu/2018/08/simple-bash-totp-script/ ###
function add_key() {
    echo "Adding a new key"
    if [ "x$1" != "x" ]; then
        identifier=$1
    else
        echo "What's the identifier?"
        read -r identifier
    fi
    echo "What's the secret?"
    read -r secret
    echo "$secret" | gpg --quiet --symmetric --out "$secretsDir/$identifier"
}

function get_totp() {
    if [ "x$1" != "x" ]; then
        identifier=$1
    else
        echo "What's the identifier?"
        read -r identifier
    fi
    secret="$(echo $PASSPHRASE | gpg --quiet --batch --passphrase-fd 0 -d "$secretsDir/$identifier")"
    TwoFAcode="$(oathtool --base32 --totp "$secret")"
}

function listSecrets() {
	printf "2paco can print codes for the following authenticators:\n"
    ls -1 "$secretsDir"
	echo
}
#################################################################

function updateScreen () { 
	/usr/bin/python3 $mainDir/update-ePaper.py $1 $2
}

function main () {
	echo "$(date +"%d/%m/%y %R") || Running as daemon..."

	# Loop start
	for (( ; ; )); do
		# Listen for requests with netcat
		PING=$(ncat --ssl -lvnp $listenPort 2>&1)

		# If we get pinged with a request
		if [ ! -z "$PING" ]; then
			data=$(echo $PING | rev | cut -d" " -f1,6 | rev)
			IP=$(echo $data | cut -d" " -f1 | rev | cut -c 2- | rev)
			request=$(echo $data | cut -d" " -f2 | cut -c 4- | cut -d"," -f1)
			PASSPHRASE=$(echo $data | cut -d" " -f2 | cut -c 4- | cut -d"," -f2)
			printf '%s || IP: %s || Request for: %s || ' "$(date +"%d/%m/%y %R")" "$IP" "$request" | tee -a $logFile

			# if we have a secret matching the request
			OK=0
			for secret in ${secrets[@]}; do
				if [[ $secret == $request ]]; then
					printf 'Approved\n' | tee -a $logFile
					
					# Generate code
					get_totp "$request"
					sleep 1

					# Print to ePaper
					echo $TwoFAcode | ncat --ssl $IP $listenPort
					OK=1
					break
				fi
			done
			if [ $OK == 0 ]; then
				# No secret matching given request
				printf 'Denied\n' | tee -a $logFile
			fi
		# Still waiting for a ping
		else
			sleep 0.1
			continue
		fi
	done
}

cat << "EOF"
  ___                        
 |__ \                       
    ) |_ __   __ _  ___ ___  
   / /| '_ \ / _` |/ __/ _ \ 
  / /_| |_) | (_| | (_| (_) |
 |____| .__/ \__,_|\___\___/ 
      | |                    
      |_|                    
	https://github.com/cysea/

EOF

function help () {
	echo
	echo	"Usage: 2paco.sh [--add [IDENTIFIER]] | [--list]"
	echo
	echo	"If ran without arguments, will work as daemon."
	echo	"Otherwise:"
	echo
	echo -e "--add     Will ask for an identifier (i.e. 'google', 'slack', ...) and\\n" \
				"         then for the secret provided by the service provider."
	echo	"--list    Will list all available identifiers."
	echo	"--help    Prints this pretty message."
}

case $1 in
	--add)
		add_key "$2"
		;;
	--list)
		listSecrets
		;;
	--help)
		help
		;;
	*)
		main
esac
