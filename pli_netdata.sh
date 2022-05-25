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
    echo
    echo
        while true; do
            read -t30 -r -p "Please enter the '--claim-token' value from the Netdata portal: " _INPUT
            if [ $? -gt 128 ]; then
                echo "timed out waiting for user response - exiting..."
                FUNC_EXIT;
            elif [[ $_INPUT != '' ]] && [[ ${#_INPUT} == 135 ]]; then
                echo 
                echo
                echo -e "${GREEN}## the provided claim token appears valid${NC}"
                echo
                echo -e "${GREEN}## proceeding to install netdata..."
                echo 
                echo
                FUNC_SETUP_NETDATA;
            else
                echo "token id invalid, please check and retry - exiting.."
                FUNC_ERR_EXIT;
                break
            fi
        done
}


FUNC_SETUP_NETDATA(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## INSTALLING NETDATA WITH CLAIM-TOKEN...${NC}"
    
    
    #echo "installing with claim-token id : $_INPUT"



    sudo curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh  --stable-channel --disable-telemetry --non-interactive \
    --claim-token $_INPUT \
    --claim-url https://app.netdata.cloud



    NDATA_CONF_FILE="/etc/netdata/netdata.conf"

    sudo sed -i.bak '/^.*history*/a \\n    process scheduling policy = idle\n    OOM score = 1000\n\n    dbengine multihost disk space = 1978\n    update every = 5\n\n[web]\n    web files owner = root\n    web files group = netdata\n\n    bind to = localhost' $NDATA_CONF_FILE
    sudo systemctl unmask netdata.service
    sudo systemctl restart netdata

    sudo systemctl status netdata
    #sleep 3s
    #FUNC_ENABLE_HEALTH_MON;
    FUNC_EXIT;
}



FUNC_ENABLE_PLI_MON(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## ENABLING NETDATA HEALTH MONITOR ALERTING...${NC}"
    


    sudo cp /usr/lib/netdata/conf.d/apps_groups.conf /etc/netdata/apps_groups.conf
    NDATA_APPS_FILE="/etc/netdata/apps_groups.conf"    
    sudo sed -i.bak '/^freeswitch*/a \\npli-node: *2_nodeStartPM2* *startNode*\npli-ei: external-initiator* *3_initiatorStartPM2* *startEI*' $NDATA_APPS_FILE


    #echo "copies the default template conf file for common system metric"

    #HEALTH_CONFS=(cpu.conf memory.conf load.conf processes.conf disks.conf tcp_resets.conf tcp_conn.conf )
    HEALTH_CONFS=(pli-node.conf pli-ei.conf)

    for i in "${HEALTH_CONFS[@]}"; do
        echo -e "${GREEN}## enabling health conf file : $i ${NC}"
        #sudo cp /usr/lib/netdata/conf.d/health.d/$i /etc/netdata/health.d/$i
        sudo cp $i /etc/netdata/health.d/$i
    
        if [ $? == 0 ]; then
           echo -e "${GREEN}## health conf file "$i" enabled successfully..${NC}"
        fi
    done


    echo
    sleep 3s
    echo -e "${GREEN}## RELOADING HEALTH DATA TO ENABLE UPDATES...${NC}"
    sudo netdatacli reload-health
    if [ $? == 0 ]; then
        echo -e "${GREEN}## health monitor settings reloaded successfully..${NC}"
    else
        echo -e "${RED}## health monitor settings reloaded failed..${NC}"
    fi

    FUNC_EXIT;
}




FUNC_RECLAIM_TOKEN(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## PERFORMING NETDATA NODE RECLAIM...${NC}"
    
    #echo "performing node reclaim process"

    sudo rm -f /var/lib/netdata/registry/netdata.public.unique.id
    echo
    echo -e "${GREEN}## RESTARTING NETDATA SERVICE...${NC}"
    sudo systemctl restart netdata
    sudo systemctl status netdata

    FUNC_EXIT;
}




FUNC_RESET_NETDATA(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## PERFORMING NETDATA UNINSTALL...${NC}"
    echo 
    echo 
    #echo "performing netdata reset process"

    sudo rm -f /etc/netdata/netdata-uninstaller.sh
    cd /etc/netdata
    sudo wget https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/netdata-uninstaller.sh && sudo chmod +x ./netdata-uninstaller.sh
    sudo ./netdata-uninstaller.sh --yes

    #if [ $? != 0 ]; then
    #  echo
    #  echo "ERROR :: Error running uninstall script.. exiting"
    #  echo 
    #  FUNC_ERR_EXIT;
    #  sleep 2s
    #fi

    echo -e "${GREEN}## PERFORMING NETDATA FOLDER CLEANUP...${NC}"
    echo 

    cd ~/
    sudo rm -rf /var/lib/netdata && sudo rm -rf /var/log/netdata
    sudo rm -rf /var/cache/apt/archives/netdata*
    sudo rm -f /var/lib/apt/lists/packagecloud.io_netdata_netdata*
    sudo rm -f /var/lib/dpkg/info/netdata-repo*
    sudo rm -rf /var/lib/netdata
    sudo rm -rf /var/cache/netdata/
    sudo rm -f /var/lib/systemd/deb-systemd-helper-masked/netdata*
    sudo rm -f /etc/apt/sources.list.d/netdata*
    sudo rm -f /var/lib/dpkg/info/netdata*
    sudo rm -rf /etc/netdata
    sudo rm -rf /opt/netdata

    sudo rm -f /etc/apt/trusted.gpg.d/netdata-archive-keyring.gpg
    sudo rm -f /etc/apt/trusted.gpg.d/netdata-edge-archive-keyring.gpg
    sudo rm -f /etc/apt/trusted.gpg.d/netdata-repoconfig-archive-keyring.gpg
    sudo rm -f /etc/cron.daily/netdata-updater
    sudo rm -f /etc/default/netdata
    sudo rm -f /etc/init.d/netdata
    sudo rm -f /etc/logrotate.d/netdata
    sudo rm -f /etc/rc2.d/S01netdata
    sudo rm -f /etc/rc3.d/S01netdata
    sudo rm -f /etc/rc4.d/S01netdata
    sudo rm -f /etc/rc5.d/S01netdata
    sudo rm -f /etc/systemd/system/multi-user.target.wants/netdata.service
    sudo rm -f /etc/systemd/system/netdata.service
    sudo rm -rf /usr/libexec/netdata
    sudo rm -f /var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/netdata.service
    sudo rm -f /var/lib/systemd/deb-systemd-helper-enabled/netdata.service.dsh-also
    
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
#FUNC_ENABLE_HEALTH_MON


case "$1" in
        -setup)
                #_OPTION="-setup"
                FUNC_GET_CLAIMTOKEN
                ;;
        -reclaim)
                #_OPTION="-conf"
                FUNC_RECLAIM_TOKEN
                ;;
        -plimon)
                #_OPTION="-conf"
                FUNC_ENABLE_PLI_MON
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
                echo -e "${GREEN}      -setup       ==  prompts for claim token id & installs netdata${NC}"
                echo -e "${GREEN}      -plimon      ==  enables goplugin node health monitor alerting${NC}"
                echo -e "${GREEN}      -reclaim     ==  removes the unique id to allow the node to be claimed again${NC}"
                echo 
                echo -e "${GREEN}      -reset       ==  **CAUTION** performs a hard reset of the netdata install removing all files${NC}"
                #echo -e "${GREEN}      -scp       ==  displays the secure copy (scp) cmds to download backup files${NC}"
                #echo
                echo 
                echo 
esac
