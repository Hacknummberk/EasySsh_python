import tkinter as tk
from tkinter import ttk
from function_main import SSHClientWrapper, VERSION
import threading
import time
import subprocess

ssh = SSHClientWrapper()

class EasySSHApp:
    def __init__(self, root):
        self.root = root
        self.root.title("easy_ssh")

        self.build_login()

    def build_login(self):
        self.clear()

        tk.Label(self.root, text="Host (user@ip)").pack()
        self.host_entry = tk.Entry(self.root)
        self.host_entry.pack()

        tk.Label(self.root, text="Password").pack()
        self.pass_entry = tk.Entry(self.root, show="*")
        self.pass_entry.pack()

        tk.Label(self.root, text="Key Path (optional)").pack()
        self.key_entry = tk.Entry(self.root)
        self.key_entry.pack()

        tk.Button(self.root, text="Connect", command=self.connect).pack()

    def connect(self):
        raw = self.host_entry.get()
        password = self.pass_entry.get()
        key = self.key_entry.get()

        user, host = raw.split("@")

        ok, msg = ssh.connect(host, user, password, key if key else None)

        if ok:
            self.build_main()
        else:
            print(msg)

    def build_main(self):
        self.clear()

        self.status = tk.Label(self.root, text="Connected")
        self.status.pack()

        self.info = tk.Label(self.root, text="")
        self.info.pack()

        self.terminal = tk.Text(self.root, height=20)
        self.terminal.pack()

        self.cmd = tk.Entry(self.root)
        self.cmd.pack()

        btn_frame = tk.Frame(self.root)
        btn_frame.pack()

        tk.Button(btn_frame, text="Send", command=self.send_cmd).pack(side="left")
        tk.Button(btn_frame, text="Clear", command=lambda: self.terminal.delete(1.0, tk.END)).pack(side="left")

        threading.Thread(target=self.update_loop, daemon=True).start()

    def send_cmd(self):
        cmd = self.cmd.get()

        if cmd.startswith("easy_ssh"):
            self.handle_custom(cmd)
        else:
            ssh.send_command(cmd)

        self.cmd.delete(0, tk.END)

    def handle_custom(self, cmd):
        parts = cmd.split()

        if parts[1] == "exit":
            ssh.disconnect()
            self.build_login()

        elif parts[1] == "version":
            self.terminal.insert(tk.END, VERSION + "\n")

        elif parts[1] == "isroot":
            self.terminal.insert(tk.END, str(ssh.is_root()) + "\n")

        elif parts[1] == "whoiam":
            self.terminal.insert(tk.END, ssh.whoami() + "\n")

        elif parts[1] == "save":
            filename = parts[3]
            fmt = parts[5]
            content = self.terminal.get(1.0, tk.END)
            result = ssh.save_log(filename, fmt, content)
            self.terminal.insert(tk.END, result + "\n")

        elif parts[1] == "webbase":
            subprocess.Popen(["python", "-m", "http.server", "5050"])

    def update_loop(self):
        while ssh.connected:
            out = ssh.get_output()
            err = ssh.get_errors()

            if out:
                self.terminal.insert(tk.END, out)

            if err:
                self.terminal.insert(tk.END, "[ERROR]\n" + err + "\n")

            ping = ssh.ping()
            cpu, ram = ssh.system_stats()

            self.info.config(
                text=f"{ssh.user}@{ssh.host} | {ping}\nCPU: {cpu}\nRAM: {ram}"
            )

            time.sleep(1)

    def clear(self):
        for widget in self.root.winfo_children():
            widget.destroy()
