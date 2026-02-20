#!/bin/bash
# Simple backup script - contains credentials
# VULNERABILITY: Hardcoded credentials
tar -czf /tmp/irc-backup-$(date +%Y%m%d).tar.gz {{ irc_log_dir }}
# Upload to backup server (not configured)
# BACKUP_USER=admin
# BACKUP_PASS=backup123
# IRC_PASSWORD=cyberpsychosis