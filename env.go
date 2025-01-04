package app

import (
	"log"

	"github.com/avila-r/env"
)

type envs struct {
	ServerURL string `env:"SERVER_URL,default=localhost:8090"`

	PocketBase struct {
		Admin struct {
			Email    string `env:"PB_ADMIN_EMAIL,default=admin@default.com"`
			Password string `env:"PB_ADMIN_PASSWORD,default=1234567890"`
		}

		DebugMode bool   `env:"PB_DEBUG_MODE,default=true"`
		PBDataDir string `env:"PB_DATA_DIR,default=./pb_data"`
	}
}

var Config = func() *envs {
	// Error handling isn't mandatory because the .env file may already be loaded by the
	// container, e.g., via Docker Compose's `env_file` directive or similar mechanisms.
	env.Load(RootPath)

	envs := envs{}
	if err := env.Decode(&envs); err != nil {
		log.Fatalf("failed to decode app environments - %v", err.Error())
	}

	return &envs
}()
