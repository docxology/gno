package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/gnolang/gno/gno.land/pkg/sdk/vm"
	"github.com/gnolang/gno/tm2/pkg/crypto"
	"github.com/gnolang/gno/tm2/pkg/crypto/secp256k1"
	"github.com/gnolang/gno/tm2/pkg/std"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run local_deploy.go <realm_directory>")
		fmt.Println("Example: go run local_deploy.go ../realms/cognitive_agent")
		os.Exit(1)
	}

	realmDir := os.Args[1]

	// Use the default gnodev key (we'll need to get the private key)
	// For now, let's create a simple test key
	privKeyBytes := []byte{0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32}
	var privKey secp256k1.PrivKeySecp256k1
	copy(privKey[:], privKeyBytes)

	address := crypto.Address(privKey.PubKey().Address())
	fmt.Printf("🚀 Deploying from address: %s\n", address.String())

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

	// For local deployment, let's try using curl to call the local node
	fmt.Printf("\n🔗 To deploy to local gnodev:\n")
	fmt.Printf("curl -X POST http://127.0.0.1:26657 -H 'Content-Type: application/json' \\\n")
	fmt.Printf("  -d '{\n")
	fmt.Printf("    \"jsonrpc\": \"2.0\",\n")
	fmt.Printf("    \"method\": \"broadcast_tx_commit\",\n")
	fmt.Printf("    \"params\": {\n")
	fmt.Printf("      \"tx\": \"<signed_transaction_here>\"\n")
	fmt.Printf("    },\n")
	fmt.Printf("    \"id\": 1\n")
	fmt.Printf("  }'\n")

	fmt.Printf("\n⚠️  Note: This requires creating a properly signed transaction for the local node.\n")
	fmt.Printf("The local gnodev uses the default account g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5\n")
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
