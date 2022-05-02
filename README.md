# Plugin Node - Proactive Monitoring with Netdata
Plugin node proactive monitoring with Netdata

A brief guide on how to install and configure Netdata to your @GoPlugin node for proactive monitoring & alerting.


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

            cd $HOME
            git clone https://github.com/inv4fee2020/pli_netdata.git
            cd pli_netdata
            chmod +x *.sh
            echo


  3. Lets run the script to begin the installation - you should have your claim-token at the ready;

            ./pli_netdata -setup

  4. 