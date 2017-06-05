package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	err := run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
}

func run() error {
	sock, err := net.Listen("tcp", ":8080")
	if err != nil {
		return err
	}
	defer sock.Close()

	for {
		client, err := sock.Accept()
		if err != nil {
			return err
		}

		fmt.Fprintf(os.Stdout, "Connection from %s\n", client.RemoteAddr())
		go func(client net.Conn) {
			buf := make([]byte, 1024)
			for {
				n, err := client.Read(buf)
				if err != nil {
					fmt.Fprintf(os.Stderr, "ERR: %s\n", err)
					client.Close()
					return
				}

				fmt.Fprintf(os.Stdout, "%d bytes: %s", n, string(buf[:n]))
			}
		}(client)
	}

	return nil
}
