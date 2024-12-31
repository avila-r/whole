package app

import "github.com/pocketbase/pocketbase"

var (
	Instance = func() *pocketbase.PocketBase {
		config := pocketbase.Config{
			DefaultDev:     Config.PocketBase.DebugMode,
			DefaultDataDir: Config.PocketBase.PBDataDir,
		}

		app := pocketbase.NewWithConfig(config)

		return app
	}()
)
