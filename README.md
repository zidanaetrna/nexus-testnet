# Nexus Node CLI Installation & Setup Guide

This guide will help you install, configure, and run the Nexus Node CLI automatically using a script. The installation process ensures all necessary dependencies are installed and configures the Nexus CLI properly.

## 🚀 Quick Installation

Run the following command to install and set up your Nexus Node automatically:

```bash
curl -sL https://raw.githubusercontent.com/zidanaetrna/nexus-testnet/refs/heads/nexus-testnet/nexus.sh | bash
```

This script will:
- Install **Rust** (if not already installed)
- Install **Nexus CLI**
- Locate the Nexus CLI installation directory
- Fix common issues in the source code
- Build and run the Nexus Node CLI

## 📜 Prerequisites

Before running the script, make sure your system meets the following requirements:
- **Ubuntu/Debian-based OS** (Other Linux distributions might require minor modifications)
- **At least 6GB RAM** (Recommended: 8GB+)
- **Minimum 16GB swap space** (Recommended: 16GB swap if RAM is 6GB)
- **cURL installed** (`sudo apt install curl -y`)

## 🛠️ Manual Installation (Optional)

If you prefer to install manually, follow these steps:

### 1️⃣ Install Rust

If Rust is not installed, run:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
```

### 2️⃣ Install Nexus CLI

```bash
curl https://cli.nexus.xyz/ | sh
```

### 3️⃣ Locate Nexus CLI Directory

Find and navigate to the installation path:

```bash
NEXUS_CLI_PATH=$(find /home -type d -path "*/.nexus/network-api/clients/cli" 2>/dev/null | head -n 1)
cd "$NEXUS_CLI_PATH"
```

### 4️⃣ Build Nexus CLI

```bash
cargo build --release
```

### 5️⃣ Fix Common Issues

#### Fix `optional` issue (if applicable)

```bash
sed -i '/optional/d' "$NEXUS_CLI_PATH/proto/orchestrator.proto"
```

#### Fix `some` issue (if applicable)

```bash
sed -i '/node_telemetry:/,/})/c\
    node_telemetry: Some(crate::nexus_orchestrator::NodeTelemetry {\
        flops_per_sec: 1,\
        memory_used: 1,\
        memory_capacity: 1,\
        location: "US".to_string(),\
    }),' "$NEXUS_CLI_PATH/src/orchestrator_client.rs"
```
#### creating swap memory if your nexus got killed automatically

```bash
fallocate -l 16G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
cd /root/.nexus/network-api/clients/cli
cargo build --release
```

#### if you already has swap memory you can turn it off first by running

```bash
swapoff -a
```


### 6️⃣ Start Nexus Node

```bash
cargo run -r -- --start --beta
```

## ✅ Verification

After starting the node, check your node details at:

🔗 **[Nexus Node Dashboard](https://app.nexus.xyz/nodes)**

1. **Log in** to Nexus
2. **Add your node**
3. **Copy your Node ID** (Do not copy `DEFAULT1`, refresh if needed)

---

### 🎯 Need Help?

If you encounter any issues, feel free to ask in the Nexus community or check the logs for errors:

```bash
tail -f ~/.nexus/logs/nexus.log
```

