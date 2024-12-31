package main

import (
	"log"

	app "github.com/avila-r/whole"
)

func main() {
	if err := app.Instance.Start(); err != nil {
		log.Fatalf("failed to run app - %v", err.Error())
	}
}
