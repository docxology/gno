#!/bin/bash

# Manual deployment script for Active Inference realms
# This script shows the exact commands to run for deployment

echo "🚀 Manual Active Inference Deployment to Testnet 8"
echo "=================================================="
echo ""

# Your details
ADDRESS="g1gn6z2xtxj3t3w8vw4tuewwpjx7j2gqwnfcrulu"
PRIVATE_KEY="05defd3cfaf562c5ee32e55802a35eaffb87f1ab491cf05a40b457d7adbf4e86"
REMOTE="https://rpc.gno.land:443"
CHAINID="testnet8"

echo "📋 Your Configuration:"
echo "Address: $ADDRESS"
echo "Remote: $REMOTE"
echo "Chain ID: $CHAINID"
echo ""

echo "🔑 Step 1: Create/Import Your Key"
echo "Since interactive gnokey isn't working, you have two options:"
echo ""
echo "Option A - If you have a seed phrase for this private key:"
echo "gnokey add active_inference_key --recover"
echo "# Then enter your seed phrase"
echo ""
echo "Option B - Create new key and transfer tokens:"
echo "gnokey add active_inference_key"
echo "# Save the new address and transfer your 10 GNOT to it"
echo ""

echo "📦 Step 2: Deploy Realms"
echo "Run these commands one by one (replace 'your_key_name' with your actual key name):"
echo ""

# Cognitive Agent
echo "🤖 Deploy Cognitive Agent Realm:"
echo "cd /Users/4d/Documents/GitHub/gno/active_inference/realms/cognitive_agent"
echo "gnokey maketx addpkg -pkgpath \"gno.land/r/$ADDRESS/cognitive_agent\" -pkgdir \".\" -gas-fee 1000000ugnot -gas-wanted 200000 -broadcast -chainid $CHAINID -remote $REMOTE your_key_name"
echo ""

# Multi-Agent System
echo "👥 Deploy Multi-Agent System Realm:"
echo "cd /Users/4d/Documents/GitHub/gno/active_inference/realms/multi_agent_system"
echo "gnokey maketx addpkg -pkgpath \"gno.land/r/$ADDRESS/multi_agent_system\" -pkgdir \".\" -gas-fee 1000000ugnot -gas-wanted 200000 -broadcast -chainid $CHAINID -remote $REMOTE your_key_name"
echo ""

# Diagnostic AI
echo "🏥 Deploy Diagnostic AI Realm:"
echo "cd /Users/4d/Documents/GitHub/gno/active_inference/realms/diagnostic_ai"
echo "gnokey maketx addpkg -pkgpath \"gno.land/r/$ADDRESS/diagnostic_ai\" -pkgdir \".\" -gas-fee 1000000ugnot -gas-wanted 200000 -broadcast -chainid $CHAINID -remote $REMOTE your_key_name"
echo ""

# Financial Trading
echo "📈 Deploy Financial Trading Realm:"
echo "cd /Users/4d/Documents/GitHub/gno/active_inference/realms/financial_trading"
echo "gnokey maketx addpkg -pkgpath \"gno.land/r/$ADDRESS/financial_trading\" -pkgdir \".\" -gas-fee 1000000ugnot -gas-wanted 200000 -broadcast -chainid $CHAINID -remote $REMOTE your_key_name"
echo ""

echo "✅ Step 3: Verify Deployment"
echo "After deployment, check your realms:"
echo "gnokey query realm gno.land/r/$ADDRESS/cognitive_agent --remote $REMOTE"
echo "gnokey query realm gno.land/r/$ADDRESS/multi_agent_system --remote $REMOTE"
echo "gnokey query realm gno.land/r/$ADDRESS/diagnostic_ai --remote $REMOTE"
echo "gnokey query realm gno.land/r/$ADDRESS/financial_trading --remote $REMOTE"
echo ""

echo "🎯 Step 4: Test Your Realms"
echo "Test the cognitive agent:"
echo "gnokey maketx call -pkgpath \"gno.land/r/$ADDRESS/cognitive_agent\" -func \"GetAgentStatus\" -gas-fee 1000000ugnot -gas-wanted 200000 -broadcast -chainid $CHAINID -remote $REMOTE your_key_name"
echo ""

echo "🌐 Web Access:"
echo "Once deployed, access via: https://testnet8.gno.land/r/$ADDRESS/realm_name"
echo ""

echo "⚠️  Important Notes:"
echo "- Make sure you have your gnokey set up first"
echo "- Each deployment costs ~1 GNOT in gas fees"
echo "- You have 10 GNOT, enough for all deployments"
echo "- Deploy one realm at a time to avoid issues"
