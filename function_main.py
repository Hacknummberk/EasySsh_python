import paramiko
import threading
import time
import socket
import platform
import os
from datetime import datetime

VERSION = "easy_ssh v1.3.7"

class SSHClientWrapper:
    def __init__(self):
        self.client = None
        self.transport = None
        self.connected = False
        self.host = ""
        self.user = ""
        self.output_buffer = []
        self.error_buffer = []
        self.keep_reading = False
        self.channel = None

    def connect(self, host, user, password=None, key_path=None):
        try:
            self.client = paramiko.SSHClient()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            if key_path and os.path.exists(key_path):
                key = paramiko.RSAKey.from_private_key_file(key_path)
                self.client.connect(hostname=host, username=user, pkey=key, timeout=5)
            else:
                self.client.connect(hostname=host, username=user, password=password, timeout=5)

            self.transport = self.client.get_transport()
            self.channel = self.transport.open_session()
            self.channel.get_pty()
            self.channel.invoke_shell()

            self.connected = True
            self.host = host
            self.user = user
            self.keep_reading = True

            threading.Thread(target=self._read_output, daemon=True).start()
            return True, "Connected"
        except Exception as e:
            self.error_buffer.append(str(e))
            return False, str(e)

    def _read_output(self):
        while self.keep_reading:
            if self.channel and self.channel.recv_ready():
                data = self.channel.recv(4096).decode(errors="ignore")
                self.output_buffer.append(data)
            time.sleep(0.1)

    def send_command(self, cmd):
        if not self.connected:
            return
        try:
            self.channel.send(cmd + "\n")
        except Exception as e:
            self.error_buffer.append(str(e))

    def disconnect(self):
        self.keep_reading = False
        if self.client:
            self.client.close()
        self.connected = False

    def get_output(self):
        data = "".join(self.output_buffer)
        self.output_buffer.clear()
        return data

    def get_errors(self):
        data = "\n".join(self.error_buffer)
        self.error_buffer.clear()
        return data

    def ping(self):
        try:
            socket.create_connection((self.host, 22), timeout=2)
            return "OK"
        except:
            return "DOWN"

    def system_stats(self):
        try:
            stdin, stdout, _ = self.client.exec_command("top -bn1 | grep 'Cpu'")
            cpu = stdout.read().decode()

            stdin, stdout, _ = self.client.exec_command("free -m")
            ram = stdout.read().decode()

            return cpu.strip(), ram.strip()
        except:
            return "N/A", "N/A"

    def is_root(self):
        try:
            stdin, stdout, _ = self.client.exec_command("id -u")
            uid = stdout.read().decode().strip()
            return uid == "0"
        except:
            return False

    def whoami(self):
        try:
            stdin, stdout, _ = self.client.exec_command("whoami")
            return stdout.read().decode().strip()
        except:
            return "unknown"

    def save_log(self, filename, fmt, content):
        try:
            path = f"{filename}.{fmt}"
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            return f"Saved to {path}"
        except Exception as e:
            return str(e)
