# pli_netdata
Plugin node proactive monitoring with Netdata

A brief guide on how to install and configure Netdata to your @GoPlugin node for proactive monitoring & alerting.


  1. Register for a new account with Netdata on their '[sign up page](https://app.netdata.cloud/?utm_source=website&utm_content=top_navigation_sign_up)'

  2. Enable email notifications by selecting 'Manage Space' -> 'Notifications' tab -> Email radio button

  3. Obtain the 'claim-token' for your space by selecting 'Manage Space' -> 'Nodes' tab & under the 'Connect nodes to _\_your\__ space'  You will see two code boxes - one using the wget command & the other for using the curl command.

  4. From either of these code boxes we want to select the claim

>curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --claim-token    >OYHFmieiuUpHWBx3VR66613McD0MEZGWMDzpx61dsLZP5tp3xD4nHra3J1Cu8bBBJkfB-mJhgGvTjRzypHlmzo244zlmRkcjaz8wnSq3fua1QjS9mop8YdCLfOUCYaVog>doKKKk --claim-rooms 870c92dd-10c4-4fa9-ba0d-4ffcc366638d --claim-url https://app.netdata.cloud