#!/bin/bash


# Get current user id and store as var
USER_ID=$(getent passwd $EUID | cut -d: -f1)

# Set Colour Vars
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

# space seperated list
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
        echo "package "$i" exists. proceeding...."
    done

}




FUNC_GET_CLAIMTOKEN(){

    FUNC_PKG_CHECK;

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
            else
                echo "token id invalid, please check and retry - exiting.."
                FUNC_ERR_EXIT;
                break
            fi
        done
}


FUNC_SETUP_NETDATA(){
    
    echo "installing with claim-token id : $_INPUT"
    FUNC_EXIT;
}



FUNC_RECLAIM_TOKEN(){
    
    echo "performing node reclaim process"
    FUNC_EXIT;
}



FUNC_RESET_NETDATA(){
    
    echo "performing netdata reset process"
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


#FUNC_PKG_CHECK
#FUNC_GET_CLAIMTOKEN


case "$1" in
        -setup)
                #_OPTION="-setup"
                FUNC_GET_CLAIMTOKEN
                ;;
        -reclaim)
                #_OPTION="-conf"
                FUNC_RECLAIM_TOKEN
                ;;
        -reset)
                #_OPTION="-conf"
                FUNC_RESET_NETDATA
                ;;
        *)
                #clear
                echo 
                echo 
                echo -e "${GREEN}Usage: $0 {function}${NC}"
                echo 
                echo -e "${GREEN}where {function} is one of the following;${NC}"
                echo 
                echo -e "${GREEN}      -setup      ==  prompts for claim token id & installs netdata${NC}"
                echo -e "${GREEN}      -reclaim    ==  removes the unique id to allow the node to be claimed again${NC}"
                echo 
                echo -e "${GREEN}      -reset      ==  **CAUTION** performs a hard reset of the netdata install removing all files${NC}"
                #echo -e "${GREEN}      -scp       ==  displays the secure copy (scp) cmds to download backup files${NC}"
                #echo
                echo 
                echo 
esac
