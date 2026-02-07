#!/usr/bin/env python3
import socket
import time
          
# IRC connection details
SERVER = "{{ irc_server }}"
PORT = 6667
NICKNAME = "bob"
PASSWORD = "{{ irc_password }}"
CHANNEL = "#general"
          
def send_msg(sock, msg):
    sock.send(f"{msg}\r\n".encode('utf-8'))
    time.sleep(0.5)
          
def main():
    # Connect to IRC server
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((SERVER, PORT))
              
    # Receive welcome message
    print(sock.recv(4096).decode('utf-8', errors='ignore'))
              
    # Send password and identify
    send_msg(sock, f"PASS {PASSWORD}")
    send_msg(sock, f"NICK {NICKNAME}")
    send_msg(sock, f"USER {NICKNAME} 0 * :{NICKNAME}")
              
    # Wait for connection to establish
    time.sleep(2)
    response = sock.recv(4096).decode('utf-8', errors='ignore')
    print(response)
              
    # Join channel
    send_msg(sock, f"JOIN {CHANNEL}")
    time.sleep(1)
              
    # Send messages
    send_msg(sock, f"PRIVMSG {CHANNEL} :Hi Alice! This CTF looks interesting.")
    time.sleep(1)
    send_msg(sock, f"PRIVMSG {CHANNEL} :Has anyone tried the crypto challenges yet?")
    time.sleep(1)
              
    # Quit
    send_msg(sock, "QUIT :Goodbye")
    sock.close()
    print("[*] Messages sent successfully")
          
if __name__ == "__main__":
    main()