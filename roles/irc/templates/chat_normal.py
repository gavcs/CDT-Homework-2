#!/usr/bin/env python3
import socket
import time
      
SERVER = "{{ irc_server }}"
PORT = 6667
NICKNAME = "bob"
CHANNEL = "#general"
      
def send_msg(sock, msg):
    sock.send(f"{msg}\r\n".encode('utf-8'))
    time.sleep(1)
      
def main():
    # Wait a bit so Alice joins first
    time.sleep(4)
          
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((SERVER, PORT))
          
    # Receive and discard welcome
    sock.recv(4096)
          
    # Authenticate
    send_msg(sock, f"PASS {PASSWORD}")
    send_msg(sock, f"NICK {NICKNAME}")
    send_msg(sock, f"USER {NICKNAME} 0 * :Bob")
          
    time.sleep(2)
    sock.recv(4096)  # Discard response
          
    # Join channel
    send_msg(sock, f"JOIN {CHANNEL}")
    time.sleep(2)
          
    # Respond to Alice
    send_msg(sock, f"PRIVMSG {CHANNEL} :Hey Alice! Yeah, I'm pumped!")
    time.sleep(3)
          
    # Ask question
    send_msg(sock, f"PRIVMSG {CHANNEL} :Which category are you starting with?")
    time.sleep(5)
          
    # Continue conversation after Alice's flag message
    time.sleep(8)
          
    send_msg(sock, f"PRIVMSG {CHANNEL} :Cool! I'll probably do the crypto ones first.")
    time.sleep(3)
          
    send_msg(sock, f"PRIVMSG {CHANNEL} :The web challenges look interesting too.")
    time.sleep(3)
          
          # Final message
    send_msg(sock, f"PRIVMSG {CHANNEL} :Sounds good! Catch you later.")
    time.sleep(2)
          
    # Quit
    send_msg(sock, "QUIT :Good luck!")
    sock.close()
    print("[*] Bob finished")
      
if __name__ == "__main__":
    main()