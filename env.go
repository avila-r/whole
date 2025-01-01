package app

import (
	"log"

	"github.com/avila-r/env"
)

type envs struct {
	ServerURL string `env:"SERVER_URL,default=localhost:8090"`

	PocketBase struct {
		DebugMode bool   `env:"PB_DEBUG_MODE,default=true"`
		PBDataDir string `env:"PB_DATA_DIR,default=./pb_data"`
	}
}

var Config = func() *envs {
	env.Load(RootPath) // Optional error handling

	envs := envs{}
	if err := env.Decode(&envs); err != nil {
		log.Fatalf("failed to decode app environments - %v", err.Error())
	}

	return &envs
}()
