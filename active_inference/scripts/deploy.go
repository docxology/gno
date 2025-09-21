package main

import (
	"encoding/hex"
	"fmt"
	"log"
	"os"

	"github.com/gnolang/gno/tm2/pkg/crypto/secp256k1"
	"github.com/gnolang/gno/tm2/pkg/std"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run deploy.go <realm_name>")
		os.Exit(1)
	}

	realmName := os.Args[1]

	// Your private key
	privKeyHex := "05defd3cfaf562c5ee32e55802a35eaffb87f1ab491cf05a40b457d7adbf4e86"

	// Decode hex private key
	privKeyBytes, err := hex.DecodeString(privKeyHex)
	if err != nil {
		log.Fatal("Failed to decode private key:", err)
	}

	// Create Gno secp256k1 private key
	var privKey secp256k1.PrivKeySecp256k1
	copy(privKey[:], privKeyBytes)

	// Get address
	address := privKey.PubKey().Address()
	fmt.Printf("Deploying from address: %s\n", address.String())

	// Create add package message
	msg := std.MsgAddPackage{
		Creator: address,
		Package: std.Package{
			Name:  realmName,
			Path:  fmt.Sprintf("gno.land/r/%s/%s", address.String(), realmName),
			Files: []std.File{}, // We'll need to load the actual files
		},
		Deposit: std.Coins{std.NewCoin("ugnot", 100000000)}, // 100 GNOT deposit
	}

	fmt.Printf("Created deployment message for realm: %s\n", realmName)
	fmt.Printf("Package path: %s\n", msg.Package.Path)

	// TODO: Load realm files and create transaction
	// This would require more setup, but shows the approach

	fmt.Println("Ready to deploy realm:", realmName)
	fmt.Println("To complete deployment, you would:")
	fmt.Println("1. Load the .gno files from the realm directory")
	fmt.Println("2. Create a complete transaction with gas and fee")
	fmt.Println("3. Sign the transaction with the private key")
	fmt.Println("4. Broadcast to the network")
}
