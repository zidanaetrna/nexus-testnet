#!/bin/bash

set -e
clear

curl -sL https://raw.githubusercontent.com/zidanaetrna/unichain/refs/heads/main/button_logo_script.sh | bash

echo "Starting Nexus Node CLI installation..."

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install Rust if not installed
if command_exists rustc; then
    echo "✅ Rust is already installed, skipping installation."
else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo "✅ Rust installed successfully."
fi

# Install Nexus CLI if not installed
if [ -d "$HOME/.nexus/network-api/clients/cli" ]; then
    echo "✅ Nexus CLI is already installed, skipping installation."
else
    echo "Installing Nexus CLI..."
    curl https://cli.nexus.xyz/ | sh
    echo "✅ Nexus CLI installed successfully."
fi

# Detect VPS username
USER_NAME=$(whoami)
NEXUS_CLI_PATH="/home/$USER_NAME/.nexus/network-api/clients/cli"

# Navigate to Nexus CLI directory
if [ -d "$NEXUS_CLI_PATH" ]; then
    echo "Entering Nexus CLI directory..."
    cd "$NEXUS_CLI_PATH"
else
    echo "❌ Error: Nexus CLI directory not found at $NEXUS_CLI_PATH."
    exit 1
fi

# Build Nexus CLI using Cargo
echo "Building Nexus CLI..."
cargo build --release

# Check if "optional" issue exists
PROTO_FILE="$NEXUS_CLI_PATH/proto/orchestrator.proto"
if grep -q "optional" "$PROTO_FILE"; then
    echo "Fixing 'optional' issue in orchestrator.proto..."
    sed -i '/optional/d' "$PROTO_FILE"
    echo "✅ 'optional' issue fixed."
else
    echo "✅ No 'optional' issue detected."
fi

# Fix "some" issue
ORCHESTRATOR_CLIENT_FILE="$NEXUS_CLI_PATH/src/orchestrator_client.rs"
if grep -q "some" "$ORCHESTRATOR_CLIENT_FILE"; then
    echo "Fixing 'some' issue in orchestrator_client.rs..."
    sed -i '/node_telemetry:/,/})/c\
    node_telemetry: Some(crate::nexus_orchestrator::NodeTelemetry {\
        flops_per_sec: 1,\
        memory_used: 1,\
        memory_capacity: 1,\
        location: "US".to_string(),\
    }),' "$ORCHESTRATOR_CLIENT_FILE"
    echo "✅ 'some' issue fixed."
else
    echo "✅ No 'some' issue detected."
fi

# Run the node
echo "Starting Nexus Node..."
cargo run -r -- --start --beta

echo "✅ Nexus Node started successfully!"
echo "➡️ Get your Node ID at: https://app.nexus.xyz/nodes"
echo "➡️ Add Node, Copy ID (Don't copy 'DEFAULT1', refresh if needed)."
