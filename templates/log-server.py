#!/usr/bin/env python3
# Simple HTTP server to view logs - NO AUTHENTICATION
import http.server
import socketserver
import os

os.chdir('/var/log/ircd')
PORT = 8080
Handler = http.server.SimpleHTTPServer if hasattr(http.server, 'SimpleHTTPServer') else http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving logs at port {PORT}")

httpd.serve_forever()