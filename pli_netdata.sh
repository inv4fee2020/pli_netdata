#!/bin/bash


# Get current user id and store as var
USER_ID=$(getent passwd $EUID | cut -d: -f1)

# Set Colour Vars
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1


REQ_PACKAGES=(git curl nano)


FUNC_PKG_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## CHECK NECESSARY PACKAGES HAVE BEEN INSTALLED...${NC}"

    for i in "${REQ_PACKAGES[@]}"
    do
        hash $i &> /dev/null
        if [ $? -eq 1 ]; then
           echo >&2 "package "$i" not found. installing...."
           sudo apt install -y "$i"
        fi
        echo "packages "$i" exist. proceeding...."
    done

}




FUNC_GET_CLAIMTOKEN(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## PROMPT FOR NETDATA SPACE CLAIM-TOKEN...${NC}"
    
        while true; do
            read -t30 -r -p "Please enter the '--claim-token' value from the Netdata portal: " _INPUT
            if [ $? -gt 128 ]; then
                echo "timed out waiting for user response - exiting..."
                FUNC_EXIT;
            elif [[ $_INPUT != '' ]] && [[ ${#_INPUT} == 135 ]]; then
                echo "token id length is valid"
                echo "the claim-token id entered is : $_INPUT"
                FUNC_SETUP_NETDATA;
            fi
        done
}


FUNC_SETUP_NETDATA(){
    
    echo "installing with claim-token id : $_INPUT"
    FUNC_EXIT;
}




FUNC_EXIT(){
	exit 0
}



FUNC_ERR_EXIT(){
    if [ $? != 0 ]; then
        #echo
        echo "ERROR - Exiting early"
        exit 1
    else
        return
    fi
}