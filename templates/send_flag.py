#!/usr/bin/env python3
import socket
import time
      
SERVER = "{{ irc_server }}"
PORT = 6667
NICKNAME = "alice"
PASSWORD = "{{ irc_password }}"
CHANNEL = "#general"
FLAG = "{{ flag }}"
      
def send_msg(sock, msg):
    sock.send(f"{msg}\r\n".encode('utf-8'))
    time.sleep(1)
      
def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((SERVER, PORT))
          
    # Receive and discard welcome
    sock.recv(4096)
          
    # Authenticate
    send_msg(sock, f"PASS {PASSWORD}")
    send_msg(sock, f"NICK {NICKNAME}")
    send_msg(sock, f"USER {NICKNAME} 0 * :Alice")
          
    time.sleep(2)
    sock.recv(4096)  # Discard response
          
    # Join channel
    send_msg(sock, f"JOIN {CHANNEL}")
    time.sleep(2)
          
    # Initial message
    send_msg(sock, f"PRIVMSG {CHANNEL} :Hey everyone! Ready for today's challenges?")
    time.sleep(3)
          
    # Wait for Bob's response (simulate by waiting)
    time.sleep(4)
          
    # Respond to Bob
    send_msg(sock, f"PRIVMSG {CHANNEL} :Yeah! I'm starting with the network challenges.")
    time.sleep(3)
          
    # Drop the flag casually
    send_msg(sock, f"PRIVMSG {CHANNEL} :By the way, I stored my notes in a secure place: {FLAG}")
    time.sleep(2)
          
    # Continue conversation
    send_msg(sock, f"PRIVMSG {CHANNEL} :Don't lose that, I'll need it later!")
    time.sleep(3)
          
    # Wait for Bob again
    time.sleep(4)
          
    # Final message
    send_msg(sock, f"PRIVMSG {CHANNEL} :Good luck! I'm going to grab some coffee.")
    time.sleep(2)
          
    # Quit
    send_msg(sock, "QUIT :Coffee break")
    sock.close()
    print("[*] Alice finished")
      
if __name__ == "__main__":
    main()