#!/bin/bash

# Comprehensive Active Inference Realm Deployment Script
# Deploys all 4 realms: cognitive_agent, diagnostic_ai, multi_agent_system, financial_trading

export PATH=$PATH:/Users/4d/go/bin
cd /Users/4d/Documents/GitHub/gno

REALMS=(
    "cognitive_agent"
    "diagnostic_ai" 
    "multi_agent_system"
    "financial_trading"
)

for realm in "${REALMS[@]}"; do
    echo "🚀 DEPLOYING $realm..."
    cd "active_inference/realms/$realm"
    
    # Create transaction
    gnokey maketx addpkg \
        --pkgpath "gno.land/r/g155vatadknr3gdq9pq6va8q4jk6gu4znklkjkce/$realm" \
        --pkgdir "." \
        --gas-fee 10000000ugnot \
        --gas-wanted 10000000 \
        --chainid dev \
        --remote "http://127.0.0.1:26657" \
        active_inference_key > tx_$realm.json
    
    echo "✅ Transaction created for $realm"
    cd /Users/4d/Documents/GitHub/gno
done

echo "🎯 ALL TRANSACTIONS CREATED! Now sign and broadcast each one:"
echo ""
echo "Run these commands (enter password when prompted):"
echo ""

for realm in "${REALMS[@]}"; do
    echo "# Sign and broadcast $realm"
    echo "cd /Users/4d/Documents/GitHub/gno/active_inference/realms/$realm"
    echo "gnokey sign tx_$realm.json --chainid dev active_inference_key"
    echo "gnokey broadcast tx_$realm.json --remote 'http://127.0.0.1:26657'"
    echo ""
done

echo "🌐 ACCESS YOUR AI SYSTEM:"
echo "http://127.0.0.1:8888/r/g155vatadknr3gdq9pq6va8q4jk6gu4znklkjkce/cognitive_agent"
echo ""
echo "🎉 YOUR COMPLETE ACTIVE INFERENCE SYSTEM IS READY! 🚀✨"
