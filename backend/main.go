package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type TopicResponse struct {
	TopicID string  `json:"topicId"`
	Title   string  `json:"title"`
	Scenes  []Scene `json:"scenes"`
}

type Scene struct {
	Index       int    `json:"index"`
	Title       string `json:"title"`
	Description string `json:"description"`
	ImageURL    string `json:"imageUrl"`
}

type QuestionsResponse struct {
	TopicID   string     `json:"topicId"`
	Questions []Question `json:"questions"`
}

type Question struct {
	Index          int      `json:"index"`
	Question       string   `json:"question"`
	Recommendation string   `json:"recommendation"`
	Options        []Option `json:"options"`
}

type Option struct {
	Text      string `json:"text"`
	IsCorrect bool   `json:"isCorrect"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Details string `json:"details,omitempty"`
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func readJSONFile[T any](path string) (T, error) {
	var out T
	b, err := os.ReadFile(path)
	if err != nil {
		return out, err
	}
	if err := json.Unmarshal(b, &out); err != nil {
		return out, err
	}
	return out, nil
}

func main() {
	const (
		addr          = ":8080"
		topicPath     = "data/tema.json"
		questionsPath = "data/preguntas.json"
	)

	mux := http.NewServeMux()

	mux.HandleFunc("/api/v1/leer_tema", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		topic, err := readJSONFile[TopicResponse](topicPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_topic",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, topic)
	})

	mux.HandleFunc("/api/v1/preguntas_tema", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[QuestionsResponse](questionsPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_questions",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	srv := &http.Server{
		Addr:              addr,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	fmt.Printf("API listening on http://0.0.0.0%s\n", addr)
	log.Fatal(srv.ListenAndServe())
}