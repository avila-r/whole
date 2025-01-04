package main

import (
	"log"

	app "github.com/avila-r/whole"

	_ "github.com/avila-r/whole/migrations"
)

func main() {
	if err := app.Instance.Start(); err != nil {
		log.Fatalf("failed to run app - %v", err.Error())
	}
}
