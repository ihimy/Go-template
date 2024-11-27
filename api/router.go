package api

import (
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/softika/gopherizer/config"
)

type Router struct {
	chi.Router

	environment string
}

func NewRouter(cfg *config.Config) *Router {
	r := chi.NewRouter()
	defaultMiddlewares(r)

	api := &Router{
		Router:      r,
		environment: cfg.App.Environment,
	}

	s := api.initServices(api.initRepositories(cfg.Database))
	h := api.initHandlers(s)

	api.initRoutes(h)
	api.initOpenApiDocs()

	return api
}

func defaultMiddlewares(r *chi.Mux) {
	r.Use(middleware.Logger)
	r.Use(middleware.CleanPath)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Heartbeat("/"))
	r.Use(middleware.NoCache)
	r.Use(middleware.AllowContentEncoding("deflate", "gzip"))
}

// HandlerFunc is API generic handler func type.
type HandlerFunc[In any, Out any] func(http.ResponseWriter, *http.Request) error

// HttpHandlerFunc creates http.HandlerFunc from custom HandlerFunc.
// It handles API errors and returns them as HTTP errors.
func (r *Router) HttpHandlerFunc(h HandlerFunc[any, any]) http.HandlerFunc {
	return func(w http.ResponseWriter, req *http.Request) {
		if err := h(w, req); err != nil {
			var apiError Error
			if errors.As(err, &apiError) {
				http.Error(w, apiError.Error(), apiError.Code)
				return
			}

			apiError = newError(http.StatusInternalServerError, "internal server error", err)
			http.Error(w, apiError.Error(), http.StatusInternalServerError)
		}
	}
}
