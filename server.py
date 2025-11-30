import http.server
import socketserver
import subprocess
import os

PORT = 8000
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/one-click-start':
            self.execute_script('install.sh')
        elif self.path == '/start':
            self.execute_script('start.sh')
        elif self.path == '/stop':
            self.execute_script('stop.sh')
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

    def execute_script(self, script_name):
        script_path = os.path.join(BASE_DIR, script_name)
        try:
            # Make sure the script is executable
            subprocess.run(['chmod', '+x', script_path], check=True)
            # Execute the script
            result = subprocess.run([script_path], check=True, capture_output=True, text=True)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(f"Script output:\n{result.stdout}".encode('utf-8'))
        except FileNotFoundError:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(f"Error: Script '{script_name}' not found.".encode('utf-8'))
        except subprocess.CalledProcessError as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Error executing script '{script_name}':\n{e.stderr}".encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"An unexpected error occurred: {e}".encode('utf-8'))

    def do_GET(self):
        if self.path == '/':
            self.path = 'index.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

Handler = MyHttpRequestHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("serving at port", PORT)
    print(f"Open http://localhost:{PORT} in your browser.")
    httpd.serve_forever()
