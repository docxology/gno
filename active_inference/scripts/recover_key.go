package main

import (
	"fmt"

	"github.com/gnolang/gno/tm2/pkg/crypto/bip39"
	"github.com/gnolang/gno/tm2/pkg/crypto/hd"
	"github.com/gnolang/gno/tm2/pkg/crypto/secp256k1"
)

func main() {
	// Gnodev default mnemonic
	mnemonic := "source bonus chronic canvas draft south burst lottery vacant surface solve popular case indicate oppose farm nothing bullet exhibit title speed wink action roast"

	// Derive the key using the fundraiser method (from the test)
	seed := bip39.NewSeed(mnemonic, "")
	master, ch := hd.ComputeMastersFromSeed(seed)
	privKey, err := hd.DerivePrivateKeyForPath(master, ch, "44'/118'/0'/0/0")
	if err != nil {
		fmt.Printf("Error deriving key: %v\n", err)
		return
	}

	gnoPrivKey := secp256k1.PrivKeySecp256k1(privKey)

	address := gnoPrivKey.PubKey().Address()

	fmt.Printf("Mnemonic: %s\n", mnemonic)
	fmt.Printf("Derived Address: %s\n", address.String())
	fmt.Printf("Expected Address: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5\n")

	if address.String() == "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" {
		fmt.Printf("✅ Address matches! Private key is valid.\n")
		fmt.Printf("Private Key (hex): %x\n", gnoPrivKey[:])
	} else {
		fmt.Printf("❌ Address doesn't match\n")
	}
}
