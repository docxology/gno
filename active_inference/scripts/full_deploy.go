package main

import (
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/gnolang/gno/gno.land/pkg/sdk/vm"
	"github.com/gnolang/gno/tm2/pkg/amino"
	"github.com/gnolang/gno/tm2/pkg/crypto"
	"github.com/gnolang/gno/tm2/pkg/crypto/secp256k1"
	"github.com/gnolang/gno/tm2/pkg/std"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run full_deploy.go <realm_directory>")
		fmt.Println("Example: go run full_deploy.go ../realms/cognitive_agent")
		os.Exit(1)
	}

	realmDir := os.Args[1]

	// Gnodev default private key (derived from mnemonic)
	privKeyHex := "ea97b9fddb7e6bf6867090a7a819657047949fbb9466d617f940538efd888605"

	// Decode hex private key
	privKeyBytes, err := hex.DecodeString(privKeyHex)
	if err != nil {
		log.Fatal("Failed to decode private key:", err)
	}

	// Create Gno secp256k1 private key
	var privKey secp256k1.PrivKeySecp256k1
	copy(privKey[:], privKeyBytes)

	// Get address
	address := crypto.Address(privKey.PubKey().Address())
	fmt.Printf("🚀 Deploying from address: %s (gnodev default)\n", address.String())

	// Get realm name from directory
	realmName := filepath.Base(realmDir)
	fmt.Printf("📦 Deploying realm: %s\n", realmName)

	// Load .gno files from realm directory
	files, err := loadGnoFiles(realmDir)
	if err != nil {
		log.Fatal("Failed to load Gno files:", err)
	}

	fmt.Printf("📄 Loaded %d files\n", len(files))

	// Create add package message
	msg := vm.NewMsgAddPackage(address, fmt.Sprintf("gno.land/r/%s/%s", address.String(), realmName), files)

	fmt.Printf("📋 Package path: gno.land/r/%s/%s\n", address.String(), realmName)

	// Create transaction manually
	tx := &std.Tx{
		Msgs: []std.Msg{msg},
		Fee: std.Fee{
			GasWanted: 8000000,                            // Higher gas as per web search
			GasFee:    std.MustParseCoin("10000000ugnot"), // Higher fee as per web search
		},
		Memo: fmt.Sprintf("Deploy %s realm", realmName),
	}

	// Sign the transaction (using test7 chain ID)
	signBytes, err := tx.GetSignBytes("test7", 0, 0)
	if err != nil {
		log.Fatal("Failed to get sign bytes:", err)
	}
	signature, err := privKey.Sign(signBytes)
	if err != nil {
		log.Fatal("Failed to sign transaction:", err)
	}

	// Add signature
	tx.Signatures = []std.Signature{{
		PubKey:    privKey.PubKey(),
		Signature: signature,
	}}

	fmt.Printf("✅ Transaction created and signed\n")

	// For now, save the transaction to a file that can be broadcast manually
	txJSON, err := amino.MarshalJSON(tx)
	if err != nil {
		log.Fatal("Failed to serialize transaction:", err)
	}

	filename := fmt.Sprintf("%s_tx.json", realmName)
	err = ioutil.WriteFile(filename, []byte(txJSON), 0644)
	if err != nil {
		log.Fatal("Failed to write transaction file:", err)
	}

	fmt.Printf("📄 Transaction saved to: %s\n", filename)
	fmt.Printf("\n🔗 To broadcast manually:\n")
	fmt.Printf("curl -X POST https://test7.gno.land:443/broadcast_tx_commit \\\n")
	fmt.Printf("  -H 'Content-Type: application/json' \\\n")
	fmt.Printf("  -d @%s\n", filename)
}

func loadGnoFiles(dir string) ([]*std.MemFile, error) {
	var files []*std.MemFile

	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !strings.HasSuffix(path, ".gno") {
			return nil
		}

		content, err := ioutil.ReadFile(path)
		if err != nil {
			return err
		}

		// Get relative path for the file name
		relPath, err := filepath.Rel(dir, path)
		if err != nil {
			return err
		}

		file := &std.MemFile{
			Name: relPath,
			Body: string(content),
		}

		files = append(files, file)
		fmt.Printf("  📄 Loaded: %s (%d bytes)\n", relPath, len(content))
		return nil
	})

	return files, err
}
