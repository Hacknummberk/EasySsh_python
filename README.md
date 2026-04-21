EasySSH (Python) — README

⚠️ Disclaimer

This repository is provided for educational and development purposes only.

- This project is not a commercial product, service, or finished application.
- It is a personal development / experimental tool created for learning, testing, and habit-building in programming and system interaction.
- The author does not guarantee security, stability, or reliability.
- You are responsible for how you use this software.

Legal Notice

- Do not use this tool for unauthorized access, intrusion, or any illegal activity.
- The author is not liable for any misuse, damage, data loss, or legal consequences.
- Use only on systems you own or have explicit permission to access.

---

📌 Project Purpose

This project exists to:

- Practice Python development
- Learn SSH communication handling
- Build lightweight UI systems for low-end devices
- Improve understanding of system automation and tooling

It is not intended to compete with professional SSH clients.

---

⚙️ How It Works (Section by Section)

1. Core Architecture

The project is split into multiple files:

"easy_ssh.py"

- Entry point of the program
- Launches the UI
- Initializes the application loop

"ui_component.py"

- Handles the user interface
- Built using lightweight components (Tkinter)
- Manages:
  - Login screen
  - Terminal display
  - Command input
  - Status updates

"function_main.py"

- Backend logic
- Handles:
  - SSH connection
  - Command execution
  - Output streaming
  - System checks (ping, CPU, RAM)

---

2. Login System

User connects using:

username@host_ip

Optional:

- Password authentication
- SSH private key authentication

Flow:

1. User enters credentials
2. Program initializes SSH client
3. Secure connection is attempted
4. If success → loads main interface

---

3. SSH Engine

Uses:

- "paramiko" (Python SSH library)

Handles:

- Secure connection
- Shell session creation
- Command execution
- Real-time output reading

---

4. Main Interface

Layout:

[Status] [user@host] [ping] [system info]

[Real-time terminal output]

[Command input] [Send] [Clear]

Features:

- Live terminal output
- Command execution
- Connection status
- Basic system stats (CPU / RAM)

---

5. Custom Commands

Built-in commands prefixed with:

easy_ssh

Available commands:

Command| Description
"easy_ssh exit"| Disconnect session
"easy_ssh version"| Show app version
"easy_ssh isroot"| Check root/sudo privileges
"easy_ssh whoiam"| Show remote username
"easy_ssh save -file name -format txt"| Save terminal output
"easy_ssh webbase"| Start local web server (port 5050)

---

6. Output Handling

- Runs in a background thread
- Continuously reads SSH channel output
- Updates UI in near real-time
- Separates:
  - Standard output
  - Error logs

---

7. Installer Script

The project includes a shell installer that:

- Checks for required tools ("git", "python", "pip")
- Installs missing dependencies
- Clones the repository
- Installs Python modules
- Verifies build environment
- Compiles into executable using "pyinstaller"

Safety Features

- Rollback on error or interruption
- Dependency validation
- Compiler verification before build

---

8. Build System

Uses:

- "pyinstaller"

Output:

- Linux → native binary
- Windows → ".exe" (when supported)

---

🧪 Development Status

This project is:

- Experimental
- Actively evolving
- Not fully tested across all environments

Expect:

- Bugs
- Missing features
- Incomplete implementations

---

🔒 Security Notes

- Credentials are not encrypted locally
- No advanced security hardening is implemented
- Intended for controlled environments only

---

📦 Requirements

- Python 3.x
- paramiko
- tkinter (usually pre-installed)
- pyinstaller (for build)

---

🚫 Not a Product

This repository:

- Is not a product
- Is not sold or distributed commercially
- Does not provide guarantees or support

It is a learning and development project created as part of programming practice and habit building.

---

📄 License

You may modify and use this code for:

- Learning
- Personal projects
- Development experiments

You may not:

- Claim it as a secure production-ready system
- Use it for illegal or unethical purposes

---

📌 Final Note

If you choose to use or modify this project, you accept full responsibility for its behavior and impact.
