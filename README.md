# IRC Server With Vulnerable Logging

## Overview
&nbsp;This repo deploys an IRC Server and 2 clients that connect and send a few things including a flag. On the server itself, there's a python bot systemd service that joins the IRC #general channel and logs every message to /var/log/ircd/messages.log with every user having access to read and write to this file. This means that if red team gets access to any user within the domain (which the server will be during the competition), they would have access to view the flag.

&nbsp;This is useful because it mimics applications such as slack or teams in how its used in a production environment. It's important to simulate the impact message logging/storage in a centralized database/server would impact a company in a real world scenario. It also acts to provide easier flags to obtain for red team because not every person is expected to have any experience in CTFs and having slightly easier flags allows them to have a good impact for the team.