#!/usr/bin/env python3
"""
Simple HTTP server to serve Flutter web build on port 8090 with caching enabled
Usage: python3 serve.py
"""

import http.server
import socketserver
import os
import sys
import hashlib
from pathlib import Path
from email.utils import formatdate

PORT = 8090
BUILD_DIR = Path(__file__).parent / "build" / "web"

# Cache durations (in seconds) - ALL DISABLED FOR NO-CACHE MODE
# Set all to 0 to disable caching completely
CACHE_DURATIONS = {
    '.html': 0,           # No cache for HTML
    '.js': 0,             # No cache for JS files
    '.css': 0,            # No cache for CSS files
    '.wasm': 0,           # No cache for WASM files
    '.json': 0,           # No cache for JSON files
    '.png': 0,            # No cache for images
    '.jpg': 0,
    '.jpeg': 0,
    '.gif': 0,
    '.svg': 0,
    '.ico': 0,
    '.woff': 0,           # No cache for fonts
    '.woff2': 0,
    '.ttf': 0,
    '.eot': 0,
    '.otf': 0,
}

class CachingHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler with caching support"""
    
    def end_headers(self):
        # Add CORS headers for development
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()
    
    def do_GET(self):
        """Handle GET requests with caching"""
        # Parse the path
        path = self.translate_path(self.path)
        
        # Handle directory requests - serve index.html
        if os.path.isdir(path):
            # Check for index.html in the directory
            index_path = os.path.join(path, 'index.html')
            if os.path.exists(index_path) and os.path.isfile(index_path):
                path = index_path
            else:
                self.send_error(404, "File not found")
                return
        
        # Check if file exists
        if not os.path.exists(path) or not os.path.isfile(path):
            self.send_error(404, "File not found")
            return
        
        # Get file stats
        stat = os.stat(path)
        file_size = stat.st_size
        modified_time = stat.st_mtime
        
        # ETag and conditional request handling DISABLED for no-cache mode
        # Always serve fresh content, never send 304 Not Modified
        # etag = hashlib.md5(f"{path}{modified_time}".encode()).hexdigest()
        
        # Skip conditional request checks - always return 200 with fresh content
        # if_none_match = self.headers.get('If-None-Match')
        # if if_none_match == etag:
        #     self.send_response(304)  # Not Modified
        #     self.end_headers()
        #     return
        
        # Read file
        try:
            with open(path, 'rb') as f:
                content = f.read()
        except IOError:
            self.send_error(500, "Error reading file")
            return
        
        # Determine content type and cache duration
        ext = os.path.splitext(path)[1].lower()
        content_type = self.guess_type(path)
        cache_duration = CACHE_DURATIONS.get(ext, 0)  # Default to 0 (no cache)
        
        # Send response with no-cache headers
        self.send_response(200)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(file_size))
        self.send_header('Last-Modified', formatdate(modified_time, usegmt=True))
        # ETag header removed - not sending ETag to prevent conditional requests
        # self.send_header('ETag', f'"{etag}"')
        
        # Always set no-cache headers
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        
        self.end_headers()
        self.wfile.write(content)
    
    def do_HEAD(self):
        """Handle HEAD requests with caching"""
        path = self.translate_path(self.path)
        
        # Handle directory requests - serve index.html
        if os.path.isdir(path):
            # Check for index.html in the directory
            index_path = os.path.join(path, 'index.html')
            if os.path.exists(index_path) and os.path.isfile(index_path):
                path = index_path
            else:
                self.send_error(404, "File not found")
                return
        
        if not os.path.exists(path) or not os.path.isfile(path):
            self.send_error(404, "File not found")
            return
        
        stat = os.stat(path)
        modified_time = stat.st_mtime
        # ETag generation disabled for no-cache mode
        # etag = hashlib.md5(f"{path}{modified_time}".encode()).hexdigest()
        
        # Skip conditional request checks
        # if_none_match = self.headers.get('If-None-Match')
        # if if_none_match == etag:
        #     self.send_response(304)
        #     self.end_headers()
        #     return
        
        ext = os.path.splitext(path)[1].lower()
        cache_duration = CACHE_DURATIONS.get(ext, 0)  # Default to 0 (no cache)
        
        self.send_response(200)
        self.send_header('Content-Type', self.guess_type(path))
        self.send_header('Content-Length', str(stat.st_size))
        self.send_header('Last-Modified', formatdate(modified_time, usegmt=True))
        # ETag header removed
        # self.send_header('ETag', f'"{etag}"')
        
        # Always set no-cache headers
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        
        self.end_headers()
    
    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS"""
        self.send_response(200)
        self.end_headers()

def kill_port(port):
    """Kill any process using the specified port"""
    import subprocess
    import platform
    
    system = platform.system()
    try:
        if system == 'Darwin' or system == 'Linux':
            # Find process using the port
            result = subprocess.run(
                ['lsof', '-ti', f':{port}'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                pids = result.stdout.strip().split('\n')
                for pid in pids:
                    if pid:
                        try:
                            subprocess.run(['kill', '-9', pid], check=True)
                            print(f"Stopped process {pid} on port {port}")
                        except subprocess.CalledProcessError:
                            pass
                # Wait a moment for port to be released
                import time
                time.sleep(0.5)
        elif system == 'Windows':
            # Windows: use netstat and taskkill
            result = subprocess.run(
                ['netstat', '-ano'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                for line in result.stdout.split('\n'):
                    if f':{port}' in line and 'LISTENING' in line:
                        parts = line.split()
                        if len(parts) > 0:
                            pid = parts[-1]
                            try:
                                subprocess.run(['taskkill', '/F', '/PID', pid], check=True)
                                print(f"Stopped process {pid} on port {port}")
                            except subprocess.CalledProcessError:
                                pass
                import time
                time.sleep(0.5)
    except Exception as e:
        print(f"Warning: Could not stop process on port {port}: {e}")

def main():
    # Check if build directory exists
    if not BUILD_DIR.exists():
        print(f"Error: Build directory '{BUILD_DIR}' not found!")
        print("Please run 'flutter build web' first.")
        sys.exit(1)
    
    # Check if port is in use and kill the process
    import subprocess
    import platform
    system = platform.system()
    
    try:
        if system == 'Darwin' or system == 'Linux':
            result = subprocess.run(
                ['lsof', '-ti', f':{PORT}'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                print(f"Port {PORT} is already in use. Stopping existing process...")
                kill_port(PORT)
        elif system == 'Windows':
            result = subprocess.run(
                ['netstat', '-ano'],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                for line in result.stdout.split('\n'):
                    if f':{PORT}' in line and 'LISTENING' in line:
                        print(f"Port {PORT} is already in use. Stopping existing process...")
                        kill_port(PORT)
                        break
    except Exception as e:
        print(f"Warning: Could not check port {PORT}: {e}")
    
    # Change to build directory
    os.chdir(BUILD_DIR)
    
    # Create server with caching handler
    Handler = CachingHTTPRequestHandler
    
    try:
        with socketserver.TCPServer(("", PORT), Handler) as httpd:
            print(f"Starting server on http://localhost:{PORT}")
            print(f"Serving directory: {BUILD_DIR.absolute()}")
            print("Caching: ENABLED")
            print("Press Ctrl+C to stop the server")
            print("")
            httpd.serve_forever()
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"Error: Port {PORT} is still in use after attempting to stop it.")
            print("Please manually stop the process using port 8090.")
        else:
            print(f"Error: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\nServer stopped.")
        sys.exit(0)

if __name__ == "__main__":
    main()

