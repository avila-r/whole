package app

import (
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"

	"github.com/avila-r/whole/ui"
)

func init() {
	Instance.OnServe().BindFunc(func(e *core.ServeEvent) error {
		e.Router.GET("/{path...}", apis.Static(ui.DistDirFS, true)).
			BindFunc(func(e *core.RequestEvent) error {
				if e.Request.PathValue(apis.StaticWildcardParam) != "" {
					e.Response.Header().Set("Cache-Control", "max-age=1209600, stale-while-revalidate=86400")
				}
				return e.Next()
			}).
			Bind(apis.Gzip())

		return e.Next()
	})
}
