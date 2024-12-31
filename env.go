package app

import (
	"log"

	"github.com/joeshaw/envdecode"

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
	env.Load(RootPath)

	env := envs{}
	if err := envdecode.StrictDecode(&env); err != nil {
		log.Fatalf("failed to decode app environments - %v", err.Error())
	}

	return &env
}()
