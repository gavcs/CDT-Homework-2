# IRC Server With Vulnerable Logging

## Overview
&emsp;This repo deploys an IRC Server and 2 clients that connect and send a few things including a flag. On the server itself, there's a python bot systemd service that joins the IRC #general channel and logs every message to /var/log/ircd/messages.log with every user having access to read and write to this file. This means that if red team gets access to any user within the domain (which the server will be during the competition), they would have access to view the flag.

&emsp;This is useful because it mimics applications such as slack or teams in how its used in a production environment. It's important to simulate the impact message logging/storage in a centralized database/server would impact a company in a real world scenario. It also acts to provide easier flags to obtain for red team because not every person is expected to have any experience in CTFs and having slightly easier flags allows them to have a good impact for the team.

## Vulnerability
&emsp;The vulnerability is that all messages sent to the IRC server are stored in plaintext in a log file (/var/log/ircd/messages.log) with every user having read and write access to it. This means anyone with access to a user in the domain can read the messages sent in the private IRC channel.

## Prerequisites
* Target OS: Ubuntu 22.04 LTS x3 (1 for each machine)
* Ansible version: 2.10+
* Python 3.10+

## Quick Start
* fix the inventory.ini file to match the information of the machines you want to use.
* ''ansible-playbook -i inventory.ini playbook.yml''

## Documentation
* both the deployment and exploitation guides are in the documentation directory.

## Competition Use Cases
Red can use this as leverage to gain more control. Blue uses to communicate with each other. Grey uses to see how people are doing in comp.
