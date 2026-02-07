#!/usr/bin/env python3
import socket
import time
          
# IRC connection details
SERVER = "100.65.7.86"
PORT = 6667
NICKNAME = "alice"
PASSWORD = "cyberpsychosis"
CHANNEL = "#general"
FLAG = "FLAG{1RC_L0GS_4R3_N0T_S3CUR3_8y_D3F4ULT}"
          
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
              
    # Send messages including flag
    send_msg(sock, f"PRIVMSG {CHANNEL} :Hey everyone, welcome to the CTF!")
    time.sleep(1)
    send_msg(sock, f"PRIVMSG {CHANNEL} :I've hidden the flag somewhere safe: {FLAG}")
    time.sleep(1)
    send_msg(sock, f"PRIVMSG {CHANNEL} :Good luck finding it! :)")
    time.sleep(1)
              
    # Quit
    send_msg(sock, "QUIT :Goodbye")
    sock.close()
    print("[*] Messages sent successfully")
          
if __name__ == "__main__":
    main()