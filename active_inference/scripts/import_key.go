package main

import (
	"encoding/hex"
	"fmt"
	"log"

	"github.com/gnolang/gno/tm2/pkg/crypto/secp256k1"
)

func main() {
	// Your private key
	privKeyHex := "05defd3cfaf562c5ee32e55802a35eaffb87f1ab491cf05a40b457d7adbf4e86"

	// Decode hex private key
	privKeyBytes, err := hex.DecodeString(privKeyHex)
	if err != nil {
		log.Fatal("Failed to decode private key:", err)
	}

	// Create Gno secp256k1 private key directly
	var privKey secp256k1.PrivKeySecp256k1
	copy(privKey[:], privKeyBytes)

	// Get public key
	pubKey := privKey.PubKey()

	// Get address
	address := pubKey.Address()

	fmt.Printf("Private Key: %s\n", privKeyHex)
	fmt.Printf("Public Key: %s\n", hex.EncodeToString(pubKey.Bytes()))
	fmt.Printf("Address: %s\n", address.String())

	// Verify this matches expected address
	expectedAddr := "g1gn6z2xtxj3t3w8vw4tuewwpjx7j2gqwnfcrulu"
	if address.String() == expectedAddr {
		fmt.Printf("✅ Address verification: MATCH\n")
	} else {
		fmt.Printf("❌ Address verification: MISMATCH\n")
		fmt.Printf("Expected: %s\n", expectedAddr)
		fmt.Printf("Got: %s\n", address.String())
	}
}
