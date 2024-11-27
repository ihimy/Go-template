package mappers

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/softika/gopherizer/internal/profile"
)

type GetProfileByIdRequest struct{}

func (g GetProfileByIdRequest) Map(r *http.Request) (profile.GetRequest, error) {
	id := r.PathValue("id")
	if id == "" {
		return profile.GetRequest{}, fmt.Errorf("path param id is missing")
	}
	return profile.GetRequest{Id: id}, nil
}

type GetProfileResponse struct{}

func (g GetProfileResponse) Map(w http.ResponseWriter, out *profile.Response) error {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	return json.NewEncoder(w).Encode(out)
}
