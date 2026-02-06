# IRC CTF Environment - Complete Package

## 📦 Package Contents

This package contains everything you need to deploy a vulnerable IRC server environment for cybersecurity CTF competitions.

### Files Included

1. **irc-ctf-playbook.yml** (11 KB)
   - Main Ansible playbook
   - Deploys IRC server with 6 intentional vulnerabilities
   - Configures clients to send flag message
   - Uses FQCN (Fully Qualified Collection Names) for all modules

2. **ansible.cfg** (1.4 KB)
   - Optimized Ansible configuration
   - Improves playbook execution speed
   - Enables logging and better output

3. **IRC_CTF_SETUP.md** (17 KB)
   - Complete setup documentation
   - Troubleshooting guide
   - Detailed installation instructions

4. **EXPLOITATION_GUIDE.md** (8.6 KB)
   - Six different exploitation methods
   - Step-by-step walkthroughs
   - Difficulty ratings for each method

5. **QUICK_REFERENCE.md** (5.1 KB)
   - Cheat sheet for participants
   - One-liner commands
   - Quick exploitation paths

6. **DIRECTORY_STRUCTURE.md** (9.5 KB)
   - Visual directory layout
   - File manifest
   - Setup checklist

7. **validate_environment.sh** (9.3 KB)
   - Automated testing script
   - 17 comprehensive tests
   - Environment validation

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Ansible 2.9+ on control node
- Ubuntu 20.04+ on target hosts
- SSH access to targets
- Your inventory.ini file

### Setup Steps

```bash
# 1. Create project directory
mkdir -p ~/irc-ctf && cd ~/irc-ctf

# 2. Copy files from this package
cp /path/to/package/* .

# 3. Add your inventory.ini file with your hosts:
cat > inventory.ini << 'EOF'
[ircserver]
gwm8432-srv01 ansible_host=100.65.7.86

[ircclients]
gwm8432-srv02 ansible_host=100.65.2.133
gwm8432-srv03 ansible_host=100.65.7.86

[all:vars]
ansible_user=cyberrange
ansible_password=frog
ansible_ssh_pass={{ ansible_password }}
ansible_python_interpreter=/usr/bin/python3
EOF

# 4. Test connectivity
ansible all -i inventory.ini -m ansible.builtin.ping

# 5. Deploy environment
ansible-playbook -i inventory.ini irc-ctf-playbook.yml

# 6. Validate deployment
./validate_environment.sh

# 7. Test exploitation
curl http://100.65.7.86:8080/messages.log | grep FLAG
```

## 🎯 Planted Vulnerabilities

### 1. World-Readable Log Directory (Easy)
- **Location**: `/var/log/ircd/` with 755 permissions
- **Exploitation**: `cat /var/log/ircd/messages.log`

### 2. Plaintext Message Logging (Easy)
- **Location**: `/var/log/ircd/messages.log` with 644 permissions
- **Exploitation**: Direct file read or HTTP access

### 3. Unauthenticated HTTP Log Server (Easy)
- **Service**: Port 8080 serving logs
- **Exploitation**: `curl http://TARGET:8080/messages.log`

### 4. Exposed Configuration Backup (Medium)
- **Location**: `/tmp/inspircd.conf.bak`
- **Contains**: Server config with operator passwords

### 5. Weak Backup Script (Medium)
- **Location**: `/usr/local/bin/irc-backup.sh`
- **Contains**: Commented hardcoded credentials

### 6. Detailed IRC Logging (Medium)
- **Config**: USERINPUT logging enabled
- **Impact**: All messages logged in plaintext

## 🏆 Flag Information

- **Flag Format**: `FLAG{1RC_L0GS_4R3_N0T_S3CUR3_8y_D3F4ULT}`
- **Location**: Sent by user "alice" in channel #general
- **Retrieval Methods**: 6 different exploitation paths

## 📂 Directory Structure

```
irc-ctf/
├── inventory.ini                    # Your hosts (CREATE THIS)
├── irc-ctf-playbook.yml            # Main playbook (PROVIDED)
├── ansible.cfg                      # Configuration (PROVIDED)
├── IRC_CTF_SETUP.md                # Setup guide (PROVIDED)
├── EXPLOITATION_GUIDE.md           # Attack methods (PROVIDED)
├── QUICK_REFERENCE.md              # Cheat sheet (PROVIDED)
├── DIRECTORY_STRUCTURE.md          # This layout (PROVIDED)
└── validate_environment.sh         # Testing script (PROVIDED)
```

## 🔧 Customization

### Change the Flag
Edit `irc-ctf-playbook.yml`:
```yaml
vars:
  flag: "FLAG{YOUR_CUSTOM_FLAG_HERE}"
```

### Adjust Difficulty

**Make Easier:**
- Add hints in web root
- Increase log file permissions
- Add obvious vulnerability markers

**Make Harder:**
- Remove HTTP server tasks
- Reduce log directory permissions to 750
- Add log rotation
- Require privilege escalation

### Add More Channels/Users
Modify the expect scripts in the playbook to:
- Join different channels
- Send more varied messages
- Create red herrings

## 🧪 Testing and Validation

### Run Validation Script
```bash
chmod +x validate_environment.sh
./validate_environment.sh
```

### Expected Output
- 17 tests total
- 100% pass rate for working environment
- Flag value displayed if found

### Manual Testing
```bash
# Test 1: HTTP Access
curl http://100.65.7.86:8080/messages.log | grep FLAG

# Test 2: SSH Access
ssh cyberrange@100.65.7.86 "cat /var/log/ircd/messages.log | grep FLAG"

# Test 3: IRC Connection
nc 100.65.7.86 6667
```

## 📚 Documentation Guide

### For CTF Organizers
Read these files in order:
1. This README (overview)
2. IRC_CTF_SETUP.md (detailed setup)
3. DIRECTORY_STRUCTURE.md (file organization)
4. Run validate_environment.sh (testing)

### For CTF Participants (Red Team)
Read these files:
1. QUICK_REFERENCE.md (start here!)
2. EXPLOITATION_GUIDE.md (detailed methods)

### For CTF Participants (Blue Team)
All files are relevant for understanding:
- How vulnerabilities were introduced
- How to detect and remediate
- How to harden IRC servers

## ⚠️ Security Warnings

**CRITICAL - READ THIS:**

- ❌ **NEVER** deploy on production networks
- ❌ **NEVER** expose to the internet
- ❌ **NEVER** use production credentials
- ✅ **ALWAYS** use isolated lab networks
- ✅ **ALWAYS** destroy after CTF
- ✅ **ALWAYS** change default passwords

## 🔍 Troubleshooting

### Issue: Playbook fails on package installation
**Solution**: Wait for apt lock or run `sudo killall apt`

### Issue: IRC server won't start
**Solution**: Check `journalctl -xeu inspircd.service`

### Issue: No messages in logs
**Solution**: Manually run client scripts in `/opt/irc-scripts/`

### Issue: Can't find flag
**Solution**: Run `grep -r FLAG /var/log/ircd/`

**Full troubleshooting guide**: See IRC_CTF_SETUP.md

## 📊 Expected Deployment Time

- **Initial setup**: 2 minutes
- **Playbook execution**: 5-8 minutes
- **Validation**: 1 minute
- **Total**: ~10 minutes

## 🎓 Learning Objectives

This environment demonstrates:
1. Insecure logging practices
2. Insufficient access controls
3. Lack of authentication on services
4. Information disclosure vulnerabilities
5. Poor security hygiene
6. Defense in depth principles

## 📝 What This Playbook Does

### Phase 1: IRC Server Setup
1. Installs InspIRCd on server host
2. Configures server with plaintext logging
3. Creates world-readable log directory
4. Sets up unauthenticated HTTP server on port 8080
5. Plants configuration backups in /tmp
6. Creates vulnerable backup scripts

### Phase 2: IRC Client Setup
1. Installs irssi and expect on client hosts
2. Creates expect scripts for automated chatting
3. Configures clients to connect to IRC server

### Phase 3: Execution
1. Runs client scripts sequentially
2. Client "alice" sends flag in #general channel
3. Other clients send normal chat messages
4. All messages logged to /var/log/ircd/messages.log

## 🛠️ Advanced Usage

### Run Only Server Setup
```bash
ansible-playbook -i inventory.ini irc-ctf-playbook.yml --limit ircserver
```

### Run Only Client Setup
```bash
ansible-playbook -i inventory.ini irc-ctf-playbook.yml --limit ircclients
```

### Verbose Output
```bash
ansible-playbook -i inventory.ini irc-ctf-playbook.yml -vvv
```

### Step Through Tasks
```bash
ansible-playbook -i inventory.ini irc-ctf-playbook.yml --step
```

## 🔄 Reset Environment

To clean up and re-deploy:

```bash
# Stop services
ansible ircserver -i inventory.ini -b -m ansible.builtin.systemd \
  -a "name=inspircd state=stopped"
  
# Remove logs
ansible ircserver -i inventory.ini -b -m ansible.builtin.file \
  -a "path=/var/log/ircd state=absent"

# Re-run playbook
ansible-playbook -i inventory.ini playbook.yml -vvv
```

## 📞 Support

For issues:
1. Check IRC_CTF_SETUP.md troubleshooting section
2. Run validate_environment.sh for diagnostics
3. Enable verbose Ansible output (-vvv)
4. Check Ansible logs in ansible.log

## 🎁 Bonus Features

The playbook includes:
- ✅ FQCN for all Ansible modules
- ✅ Idempotent operations
- ✅ Proper error handling
- ✅ Sequential client execution
- ✅ Wait conditions for services
- ✅ Systemd service management
- ✅ Multiple exploitation vectors

## 📦 Package Summary

| Component | Purpose | Size |
|-----------|---------|------|
| Playbook | Deployment automation | 11 KB |
| Setup Guide | Installation instructions | 17 KB |
| Exploit Guide | Attack walkthroughs | 8.6 KB |
| Quick Reference | Cheat sheet | 5.1 KB |
| Validator | Testing automation | 9.3 KB |
| **Total** | **Complete CTF environment** | **~60 KB** |

## 🚩 Success Criteria

Environment is ready when:
- ✅ InspIRCd running on port 6667
- ✅ HTTP server running on port 8080
- ✅ Message logs contain flag
- ✅ Logs are world-readable
- ✅ Flag retrievable via HTTP
- ✅ All validation tests pass

## 🎯 Next Steps

1. ✅ Copy all files to your project directory
2. ✅ Create inventory.ini with your hosts
3. ✅ Run ansible-playbook command
4. ✅ Validate with testing script
5. ✅ Distribute to CTF participants
6. ✅ Monitor exploitation attempts
7. ✅ Provide hints if needed
8. ✅ Clean up after event

---

**Ready to deploy your IRC CTF environment?**

Start with the Quick Start section above, then refer to IRC_CTF_SETUP.md for detailed instructions.

Good luck with your cybersecurity tournament! 🚩

**Version**: 1.0  
**Last Updated**: January 2026  
**Created for**: Cybersecurity CTF Competitions
