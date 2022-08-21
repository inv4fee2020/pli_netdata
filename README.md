# Plugin Node - Proactive Monitoring with Netdata
Plugin node proactive monitoring with Netdata

A brief guide on how to install and configure Netdata to your @GoPlugin node for proactive monitoring & alerting.

---
### Accompanying video for visual aid.

[Youtube Playlist : Plugin ($PLI ) Node - Proactive Monitoring - UpTimeRobot & NetData](https://www.youtube.com/watch?v=3EcVNHADik0&list=PL2_76-uvpc8xr4h22XCpayMVgdKPbhy2b)

---
## Netdata : Register account & obtain 'claim-token'

  1. Register for a new account with Netdata on their '[sign up page](https://app.netdata.cloud/?utm_source=website&utm_content=top_navigation_sign_up)'

  2. Enable email notifications by selecting 'Manage Space' -> 'Notifications' tab -> Email radio button
        https://learn.netdata.cloud/docs/cloud/alerts-notifications/notifications

  3. Obtain the 'claim-token' for your space by selecting 'Manage Space' -> 'Nodes' tab & under the 'Connect nodes to _\_your\__ space'  You will see two code boxes - one using the wget command & the other for using the curl command.

  4. From either of these code boxes we want to select the _'--claim-token'_ text only.

  From the below example text, you can see the at the end of the first line the _'--claim-token'_ word. Immediately after this marks the start of the text selection that we want.  We select the token string all the way up to the start of the _'--claim-rooms'_ word.

>curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --claim-token    OYHFmieiuUpHWBx3VR66613McD0MEZGWMDzpx61dsLZP5tp3xD4nHra3J1Cu8bBBJkfB-mJhgGvTjRzypHlmzo244zlmRkcjaz8wnSq3fua1QjS9mop8YdCLfOUCYaVogdoKKKk --claim-rooms 870c92dd-10c4-4fa9-ba0d-4ffcc366638d --claim-url https://app.netdata.cloud

---

the following shows the text to select & copy in **BOLD**...

>curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --claim-token    **OYHFmieiuUpHWBx3VR66613McD0MEZGWMDzpx61dsLZP5tp3xD4nHra3J1Cu8bBBJkfB-mJhgGvTjRzypHlmzo244zlmRkcjaz8wnSq3fua1QjS9mop8YdCLfOUCYaVogdoKKKk** --claim-rooms 870c92dd-10c4-4fa9-ba0d-4ffcc366638d --claim-url https://app.netdata.cloud

---
---

## Netdata : VPS Setup

The following steps will now setup your VPS to report data into your Netdata 'General' space using the 'claim-token' that we obtained in the previous steps.

  1. Logon to your VPS with your admin user account

  2. We now clone down the 'pli_netdata' scripts as follows;

```
    cd $HOME
    git clone https://github.com/inv4fee2020/pli_netdata.git
    cd pli_netdata
    chmod +x *.sh
    echo
```


  3. Lets run the script to begin the installation - you should have your claim-token at the ready;

```
    ./pli_netdata.sh -setup
```


  4. You will be prompted to provide the _'--claim-token'_ from the previous section above;
     Also note that the user input has a timeout.


```
    #########################################################################
    ## PROMPT FOR NETDATA SPACE CLAIM-TOKEN...


    Please enter the '--claim-token' value from the Netdata portal:
```

   Immediately after entering the token, the script will check that the provided token is 135 characters in length. If valid the installation will continue as shown by the following messages and various components being downloaded;

```
    ## the provided claim token appears valid

    ## proceeding to install netdata...


    #########################################################################
    ## INSTALLING NETDATA WITH CLAIM-TOKEN...
```

  5. While the script restarts the netdata services in order to load the new changes, it is strongly recommeneded that you perform a full reboot of your VPS.  This is due to scenarios where the detection of changes in the plugin processes do not trigger notifications. A reboot resolves this.


## Netdata : Updating the current installation

When running the `-update` command the script will also apply necessary linux system updates necessary for the netdata update.

When you reach the following section of the update, you will need to confirm the DEFAULT action to maintain your existing netdata.conf settings

    Configuration file '/etc/netdata/netdata.conf'
     ==> Modified (by you or by a script) since installation.
     ==> Package distributor has shipped an updated version.
       What would you like to do about it ?  Your options are:
        Y or I  : install the package maintainer's version
        N or O  : keep your currently-installed version
          D     : show the differences between the versions
          Z     : start a shell to examine the situation
     The default action is to keep your current version.
    *** netdata.conf (Y/I/N/O/D/Z) [default=N] ?

Once you have confirmed this the update should continue with no further user interaction. You can then check the version within your netdata cloud portal.

---

### What if I already have Netdata installed - How can I benefit from this update?

Assuming you have made no customisations since installing NetData, then by simply following the above setup process and supplying the _'--claim-token'_ for the space where your existing node is defined e.g. by default this is the 'General' war room, the node will continue to be displayed as before, but will be re-installed with the new settings.

### What settings are applied by this script?

1. This script updates the main 'netdata.conf' file to implement the following settings;

    - Sets polling to every 5 seconds (rather than the default every 1 second)
    - Stores 30 days worth of data on the local disk which averages to about 2GB of data using the '[Change how long Netdata stores metrics](https://learn.netdata.cloud/docs/store/change-metrics-storage)' page.


2. The script updates the 'apps_groups.conf' file to implement the config to define the plugin processes. It does this by adding the following lines under the '# other application servers' section;

        pli-node: *2_nodeStartPM2* *startNode*
        pli-ei: external-initiator *3_initiatorStartPM2* *startEI*


3. The script then copies over the following alert configuration files to the 'health.d' folder where netdata reads conf file in order to produce the email notifications when the processes are not running.

    - pli-node.conf
    - pli-ei.conf


---
## Usage syntax

Basic script syntax;

    Usage: ./pli_netdata.sh {function}

    where {function} is one of the following;

          -setup       ==  prompts for claim token id & installs netdata
          -update      ==  updates /reinstalls netdata with existing config
          -base-alerts ==  enables base system health monitor alerting
          -reclaim     ==  removes the unique id to allow the node to be claimed again

          -reset       ==  **CAUTION** performs a hard reset of the netdata install removing all files

