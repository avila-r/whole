package migrations

import (
	"github.com/pocketbase/pocketbase/core"
	m "github.com/pocketbase/pocketbase/migrations"

	app "github.com/avila-r/whole"
)

func init() {
	m.Register(
		func(c core.App) error {
			superusers, err := c.FindCollectionByNameOrId(core.CollectionNameSuperusers)
			if err != nil {
				return err
			}

			record := core.NewRecord(superusers)

			record.Set("email", app.Config.PocketBase.Admin.Email)
			record.Set("password", app.Config.PocketBase.Admin.Password)

			return c.Save(record)
		},

		func(c core.App) error {
			record, _ := c.FindAuthRecordByEmail(core.CollectionNameSuperusers, app.Config.PocketBase.Admin.Email)
			if record == nil {
				return nil // already deleted
			}

			return c.Delete(record)
		},
	)
}
