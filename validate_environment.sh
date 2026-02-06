#!/bin/bash
# IRC CTF Environment Validation Script
# Tests all components after playbook execution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IRC_SERVER="100.65.7.86"
IRC_PORT="6667"
HTTP_PORT="8080"
SSH_USER="cyberrange"
SSH_PASS="frog"
INVENTORY="/home/cyberrange/grey-team-irc/inventory.ini"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_test() {
    echo -e "${YELLOW}[TEST $TOTAL_TESTS]${NC} $1"
}

run_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

print_pass() {
    echo -e "${GREEN}  ✓ PASS${NC} - $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

print_fail() {
    echo -e "${RED}  ✗ FAIL${NC} - $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

print_info() {
    echo -e "${BLUE}  ℹ INFO${NC} - $1"
}

# Start testing
print_header "IRC CTF Environment Validation"
echo ""

# Test 1: Ansible connectivity
run_test
print_test "Ansible connectivity to all hosts"
if ansible all -i "$INVENTORY" -m ansible.builtin.ping &>/dev/null; then
    print_pass "All hosts reachable via Ansible"
else
    print_fail "Cannot reach hosts via Ansible"
fi

# Test 2: IRC Server Process
run_test
print_test "InspIRCd service status"
if ansible ircserver -i "$INVENTORY" -a "systemctl is-active inspircd" -b 2>/dev/null | grep -q "active"; then
    print_pass "InspIRCd service is running"
else
    print_fail "InspIRCd service is not running"
fi
echo ""

# Test 3: IRC Port Listening
run_test
print_test "IRC server listening on port $IRC_PORT"
if ansible ircserver -i "$INVENTORY" -a "netstat -tulpn | grep :$IRC_PORT" -b 2>/dev/null | grep -q "$IRC_PORT"; then
    print_pass "IRC server listening on port $IRC_PORT"
else
    print_fail "IRC server not listening on port $IRC_PORT"
fi
echo ""

# Test 4: HTTP Log Server
run_test
print_test "HTTP log server service status"
if ansible ircserver -i "$INVENTORY" -a "systemctl is-active irc-log-server" -b 2>/dev/null | grep -q "active"; then
    print_pass "HTTP log server is running"
else
    print_fail "HTTP log server is not running"
fi
echo ""

# Test 5: HTTP Port Listening
run_test
print_test "HTTP server listening on port $HTTP_PORT"
if ansible ircserver -i "$INVENTORY" -a "netstat -tulpn | grep :$HTTP_PORT" -b 2>/dev/null | grep -q "$HTTP_PORT"; then
    print_pass "HTTP server listening on port $HTTP_PORT"
else
    print_fail "HTTP server not listening on port $HTTP_PORT"
fi
echo ""

# Test 6: HTTP Accessibility
run_test
print_test "HTTP server accessible from control node"
if curl -s --connect-timeout 5 "http://$IRC_SERVER:$HTTP_PORT/" > /dev/null; then
    print_pass "HTTP server accessible via curl"
else
    print_fail "HTTP server not accessible"
fi
echo ""

# Test 7: IRC Log Directory Exists
run_test
print_test "IRC log directory exists"
if ansible ircserver -i "$INVENTORY" -a "test -d /var/log/ircd && echo exists" -b 2>/dev/null | grep -q "exists"; then
    print_pass "Log directory /var/log/ircd exists"
    
    # Check permissions
    PERMS=$(ansible ircserver -i "$INVENTORY" -a "stat -c %a /var/log/ircd" -b 2>/dev/null | grep -o '[0-9]\{3\}' | tail -1)
    if [ "$PERMS" = "755" ]; then
        print_pass "Log directory has vulnerable permissions (755)"
    else
        print_info "Log directory permissions: $PERMS (expected 755)"
    fi
else
    print_fail "Log directory /var/log/ircd does not exist"
fi
echo ""

# Test 8: Message Log File Exists
run_test
print_test "Message log file exists"
if ansible ircserver -i "$INVENTORY" -a "test -f /var/log/ircd/messages.log && echo exists" -b 2>/dev/null | grep -q "exists"; then
    print_pass "Message log file exists"
    
    # Check permissions
    PERMS=$(ansible ircserver -i "$INVENTORY" -a "stat -c %a /var/log/ircd/messages.log" -b 2>/dev/null | grep -o '[0-9]\{3\}' | tail -1)
    if [ "$PERMS" = "644" ]; then
        print_pass "Message log has vulnerable permissions (644)"
    else
        print_info "Message log permissions: $PERMS (expected 644)"
    fi
else
    print_fail "Message log file does not exist"
fi
echo ""

# Test 9: Log File Has Content
run_test
print_test "Message log file has content"
LOG_LINES=$(ansible ircserver -i "$INVENTORY" -a "wc -l /var/log/ircd/messages.log" -b 2>/dev/null | grep -o '[0-9]\+' | head -1)
if [ ! -z "$LOG_LINES" ] && [ "$LOG_LINES" -gt 0 ]; then
    print_pass "Message log has $LOG_LINES lines of content"
else
    print_fail "Message log is empty or unreadable"
fi
echo ""

# Test 10: Flag Present in Logs
run_test
print_test "Flag present in message logs"
if ansible ircserver -i "$INVENTORY" -a "grep -q 'FLAG{' /var/log/ircd/messages.log && echo found" -b 2>/dev/null | grep -q "found"; then
    print_pass "Flag found in message logs"
    
    # Extract and display the flag
    FLAG=$(ansible ircserver -i "$INVENTORY" -a "grep -o 'FLAG{[^}]*}' /var/log/ircd/messages.log" -b 2>/dev/null | grep -o 'FLAG{[^}]*}' | head -1)
    if [ ! -z "$FLAG" ]; then
        print_info "Flag value: $FLAG"
    fi
else
    print_fail "Flag not found in message logs"
fi
echo ""

# Test 11: Flag Accessible via HTTP
run_test
print_test "Flag accessible via HTTP"
HTTP_FLAG=$(curl -s "http://$IRC_SERVER:$HTTP_PORT/messages.log" 2>/dev/null | grep -o 'FLAG{[^}]*}' | head -1)
if [ ! -z "$HTTP_FLAG" ]; then
    print_pass "Flag accessible via HTTP"
    print_info "Flag via HTTP: $HTTP_FLAG"
else
    print_fail "Cannot retrieve flag via HTTP"
fi
echo ""

# Test 12: Configuration Backup Exists
run_test
print_test "Configuration backup file exists"
if ansible ircserver -i "$INVENTORY" -a "test -f /tmp/inspircd.conf.bak && echo exists" -b 2>/dev/null | grep -q "exists"; then
    print_pass "Config backup exists at /tmp/inspircd.conf.bak"
else
    print_fail "Config backup not found"
fi
echo ""

# Test 13: Backup Script Exists
run_test
print_test "IRC backup script exists"
if ansible ircserver -i "$INVENTORY" -a "test -f /usr/local/bin/irc-backup.sh && echo exists" -b 2>/dev/null | grep -q "exists"; then
    print_pass "Backup script exists at /usr/local/bin/irc-backup.sh"
    
    # Check for hardcoded credentials
    if ansible ircserver -i "$INVENTORY" -a "grep -q 'BACKUP_PASS' /usr/local/bin/irc-backup.sh && echo found" -b 2>/dev/null | grep -q "found"; then
        print_pass "Backup script contains hardcoded credentials"
    fi
else
    print_fail "Backup script not found"
fi
echo ""

# Test 14: Client Scripts Exist
run_test
print_test "IRC client expect scripts exist"
CLIENT_SCRIPTS=$(ansible ircclients -i "$INVENTORY" -a "ls /opt/irc-scripts/*.exp 2>/dev/null | wc -l" -b 2>/dev/null | grep -o '[0-9]\+' | head -1)
if [ ! -z "$CLIENT_SCRIPTS" ] && [ "$CLIENT_SCRIPTS" -gt 0 ]; then
    print_pass "Found $CLIENT_SCRIPTS client script(s)"
else
    print_fail "No client scripts found"
fi
echo ""

# Test 15: IRC Configuration Valid
run_test
print_test "IRC server configuration syntax"
if ansible ircserver -i "$INVENTORY" -a "test -f /etc/inspircd/inspircd.conf && echo exists" -b 2>/dev/null | grep -q "exists"; then
    print_pass "IRC configuration file exists"
    
    # Check for logging configuration
    if ansible ircserver -i "$INVENTORY" -a "grep -q 'USERINPUT' /etc/inspircd/inspircd.conf && echo found" -b 2>/dev/null | grep -q "found"; then
        print_pass "Detailed logging (USERINPUT) is enabled"
    fi
else
    print_fail "IRC configuration file not found"
fi
echo ""

# Test 16: Network Connectivity
run_test
print_test "Network connectivity from clients to server"
if ansible ircclients -i "$INVENTORY" -a "nc -zv $IRC_SERVER $IRC_PORT" 2>&1 | grep -q "succeeded"; then
    print_pass "Clients can reach IRC server"
else
    print_fail "Clients cannot reach IRC server"
fi
echo ""

# Test 17: SSH Access Works
run_test
print_test "SSH access with provided credentials"
if sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$SSH_USER@$IRC_SERVER" "echo success" 2>/dev/null | grep -q "success"; then
    print_pass "SSH access works with provided credentials"
else
    print_fail "SSH access failed"
fi
echo ""

# Summary
print_header "Test Summary"
echo ""
echo -e "Total Tests:  ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
echo ""

# Calculate success rate
SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo -e "Success Rate: ${BLUE}$SUCCESS_RATE%${NC}"
echo ""

# Final verdict
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    echo -e "${GREEN}Environment is ready for CTF!${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
elif [ $SUCCESS_RATE -ge 80 ]; then
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}⚠ MOSTLY OPERATIONAL${NC}"
    echo -e "${YELLOW}Some tests failed, but environment may be usable${NC}"
    echo -e "${YELLOW}========================================${NC}"
    exit 1
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ TESTS FAILED${NC}"
    echo -e "${RED}Environment needs attention${NC}"
    echo -e "${RED}========================================${NC}"
    exit 2
fi