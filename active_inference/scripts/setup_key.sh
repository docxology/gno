#!/bin/bash

# Key setup script for Active Inference deployment

echo "🔑 Setting up Gno Key for Active Inference Deployment"
echo "===================================================="
echo ""

PRIVATE_KEY="05defd3cfaf562c5ee32e55802a35eaffb87f1ab491cf05a40b457d7adbf4e86"
ADDRESS="g1gn6z2xtxj3t3w8vw4tuewwpjx7j2gqwnfcrulu"

echo "Your Private Key: $PRIVATE_KEY"
echo "Expected Address: $ADDRESS"
echo ""

echo "⚠️  IMPORTANT: This private key will be used to sign transactions."
echo "Make sure you're in a secure environment before proceeding."
echo ""

echo "Since interactive gnokey commands aren't working in this environment,"
echo "please run one of these commands manually in your terminal:"
echo ""

echo "Option 1 - If you have a seed phrase for this private key:"
echo "gnokey add active_inference_key --recover"
echo "# Then enter your 12/24 word seed phrase when prompted"
echo ""

echo "Option 2 - Create a new key (you'll need to transfer tokens):"
echo "gnokey add active_inference_key"
echo "# This creates a new address - you'll need to send your 10 GNOT there"
echo ""

echo "Option 3 - Use existing key if you already have one:"
echo "gnokey list  # to see your existing keys"
echo ""

echo "After setting up your key, verify it:"
echo "gnokey list"
echo ""

echo "Your key should show address: $ADDRESS"
echo "If it doesn't match, you may need to use Option 2 and transfer tokens."
echo ""

echo "Once your key is set up, run the deployment commands from manual_deploy.sh"
