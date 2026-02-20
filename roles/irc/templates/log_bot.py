#!/usr/bin/env python3
import socket
import time
from datetime import datetime

SERVER = "127.0.0.1"
PORT = 6667
PASSWORD = "{{ irc_password }}"
NICKNAME = "logger"
CHANNEL = "#general"
LOGFILE = "/var/log/ircd/messages.log"

def log_message(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOGFILE, 'a') as f:
        f.write(f"{timestamp} {msg}\n")

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((SERVER, PORT))

sock.send(f"PASS {PASSWORD}\r\n".encode())
sock.send(f"NICK {NICKNAME}\r\n".encode())
sock.send(f"USER {NICKNAME} 0 * :Logger Bot\r\n".encode())

time.sleep(2)
sock.send(f"JOIN {CHANNEL}\r\n".encode())

while True:
    try:
        data = sock.recv(4096).decode('utf-8', errors='ignore')
        if not data:
            break

        for line in data.split('\r\n'):
            if line:
                log_message(line)

                # Handle PING
                if line.startswith('PING'):
                    sock.send(f"PONG {line.split()[1]}\r\n".encode())

                # Log channel messages
                if 'PRIVMSG' in line and CHANNEL in line:
                    log_message(line)
    except:
        break

sock.close()