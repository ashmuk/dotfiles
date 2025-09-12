# Command Reference Guide

A comprehensive reference for common shell commands organized by category.

## Table of Contents

- [File Operations](#file-operations)
- [Network & Communication](#network--communication)
- [System Monitoring & Resource Management](#system-monitoring--resource-management)
- [Text Processing & Data Manipulation](#text-processing--data-manipulation)
- [Package & Environment Management](#package--environment-management)
- [DevOps & Security](#devops--security)
- [Utility Tools](#utility-tools)

---

## File Operations

### Directory Listing
```bash
# Basic listing with human-readable sizes
ls -lh

# Enhanced listing with git status (if exa is available)
exa -l --git
```

### File Search
```bash
# Find files by name pattern
find . -name "*.log"

# Fast file search (if fd is available)
fd "config" .
```

### File Content Viewing
```bash
# View first 20 lines
head -n 20 /var/log/syslog

# Follow file changes in real-time
tail -f /var/log/syslog
```

### File Comparison
```bash
# Show differences between files
diff old.conf new.conf

# Visual diff in vim
vimdiff old.conf new.conf
```

### Compression & Archiving
```bash
# Create compressed archive
tar -czvf backup.tar.gz ./project

# Extract compressed archive
tar -xzvf backup.tar.gz
```

---

## Network & Communication

### Connectivity Testing
```bash
# Test network connectivity
ping google.com

# Trace network route
traceroute google.com

# Continuous monitoring (if mtr is available)
mtr google.com
```

### HTTP Requests
```bash
# Get HTTP headers only
curl -I https://example.com

# HTTP requests with httpie
http GET https://example.com
```

### SSH & File Transfer
```bash
# Connect to remote host
ssh user@remote-host

# Copy file to remote host
scp ./file.txt user@remote-host:/tmp/

# Synchronize directories
rsync -avz ./data/ user@remote-host:/srv/data/
```

### Port & Network Analysis
```bash
# Show listening ports
ss -tulnp

# Show processes using specific port
lsof -i :8080
```

### DNS Lookup
```bash
# Detailed DNS query
dig openai.com

# Simple DNS lookup
nslookup openai.com
```

---

## System Monitoring & Resource Management

### Process Management
```bash
# Interactive process monitor
top

# Enhanced process monitor (if htop is available)
htop

# Find specific processes
ps aux | grep python

# Terminate process forcefully
kill -9 <PID>
```

### Disk & Storage
```bash
# Show disk usage
df -h

# Show directory sizes
du -sh *
```

### Memory Monitoring
```bash
# Show memory usage
free -h

# Show memory statistics
vmstat 2 5
```

### I/O Monitoring
```bash
# Show I/O statistics
iostat -xz 1

# Interactive I/O monitor (if iotop is available)
iotop
```

### Log Analysis
```bash
# Show recent kernel messages
dmesg | tail

# Show service logs
journalctl -u ssh.service --since "10 min ago"
```

---

## Text Processing & Data Manipulation

### Text Search
```bash
# Search for patterns in files
grep "ERROR" /var/log/syslog

# Fast text search (if ripgrep is available)
rg "TODO" src/
```

### Text Processing
```bash
# Extract, sort, and count unique values
cat file.txt | cut -d',' -f2 | sort | uniq -c

# Replace text in file
sed -i 's/foo/bar/g' file.txt

# Extract specific columns
awk '{print $1,$3}' access.log
```

### JSON & YAML Processing
```bash
# Parse JSON data
cat data.json | jq '.users[0].name'

# Parse YAML data (if yq is available)
yq '.spec.template' deployment.yaml
```

### Binary File Analysis
```bash
# Show binary file content in hex
xxd binaryfile | head
```

---

## Package & Environment Management

### macOS
```bash
# Install packages with Homebrew
brew install wget
```

### Ubuntu/Debian
```bash
# Update package list and install build tools
sudo apt update && sudo apt install -y build-essential
```

### Python
```bash
# Install Python packages
pip install requests

# Run tools without installing (if pipx is available)
pipx run black file.py
```

### Java
```bash
# Install Java with SDKMAN
sdk install java 17.0.10-tem

# Build Maven project
mvn clean package
```

### Node.js
```bash
# Install global packages
npm install -g eslint

# Add dependencies with Yarn
yarn add lodash
```

### Git
```bash
# Clone repository
git clone https://github.com/org/repo.git

# Show differences
git diff

# Show commit history
git log --oneline --graph
```

### Docker
```bash
# Build Docker image
docker build -t myapp .

# Run Docker container
docker run -it --rm myapp
```

### Kubernetes
```bash
# List pods
kubectl get pods

# Describe pod details
kubectl describe pod mypod
```

### Terraform
```bash
# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply
```

---

## DevOps & Security

### Encryption & Hashing
```bash
# Generate RSA private key
openssl genrsa -out key.pem 2048

# Calculate file checksum
sha256sum file.txt
```

---

## Utility Tools

### Session Management
```bash
# Create new tmux session
tmux new -s dev

# Attach to existing session
tmux attach -t dev
```

### Periodic Execution
```bash
# Run command every 2 seconds
watch -n 2 "df -h"
```

### Performance Measurement
```bash
# Measure execution time
time python script.py
```

### Command Location
```bash
# Find command path
which python

# Show command type
type ls

# Find command location
whereis java
```

### Documentation
```bash
# Show manual page
man tar

# Show simplified help (if tldr is available)
tldr tar
```

---

## Notes

- Commands marked with "(if [tool] is available)" require additional tools to be installed
- Some commands may have different options or syntax depending on your operating system
- Always check command documentation with `man [command]` for detailed usage information
