package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"time"
	// "net/SplitHostPort"
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

/*
	 ----------------------------------------------------------------------
			Segunda Bloque de Campos complementarios a los  temas para la App
	   ----------------------------------------------------------------------
*/
type VerseResponse struct {
	TopicID     string `json:"topicId"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Verse       string `json:"verse"`
}

type PrayerResponse struct {
	TopicID string       `json:"topicId"`
	Title   string       `json:"title"`
	Prayer  string       `json:"prayer"`
	Verses  []ListVerses `json:"verses"`
}
type ListVerses struct {
	Verse string `json:"verse"`
}

type ChallengeResponse struct {
	TopicID       string          `json:"topicId"`
	Title         string          `json:"title"`
	Description   string          `json:"description"`
	ListChallenge []ListChallenge `json:"listChallenge"`
}
type ListChallenge struct {
	Challenge string `json:"challenge"`
	Tips      string `json:"tips"`
}

type MessageAuditionResponse struct {
	TopicID   string `json:"topicId"`
	Title     string `json:"title"`
	URL_Audio string `json:"audio_url"`
}

/*
	 ----------------------------------------------------------------------
			Tercer Bloque de Campos complementarios a los  temas para la App
	   ----------------------------------------------------------------------
*/
type HelpResponse struct {
	TopicId string `json:"topicId"`
	Title   string `json:"title"`
	Help    string `json:"help"`
}

type AwardsResponse struct {
	TopicId string  `json:"topicId"`
	Title   string  `json:"title"`
	Prayer  string  `json:"prayer"`
	Awards  []Award `json:"awards"`
}

type Award struct {
	Award string `json:"award"`
}

type DonationsResponse struct {
	TopicId  string  `json:"topicId"`
	Title    string  `json:"title"`
	Prayer   string  `json:"prayer"`
	Teaching []Teach `json:"teaching"`
}

type TeachingsResponse struct {
	TopicId  string  `json:"topicId"`
	Title    string  `json:"title"`
	Prayer   string  `json:"prayer"`
	Teaching []Teach `json:"teaching"`
}

type Teach struct {
	Teach string `json:"teach"`
}

type MinisteryResponse struct {
	TopicId string           `json:"topicId"`
	Title   string           `json:"title"`
	Base    string           `json:"base"`
	Verses  []VerseMinistery `json:"verses"`
}

type VerseMinistery struct {
	Verse string `json:"verseMinistery"`
}

/*
	 ----------------------------------------------------------------------
			Funciones de Gestión de archivos JSON
	   ----------------------------------------------------------------------
*/
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

/*
	func logRequests(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			inicio := time.Now()
			log.Printf("--> %s %s desde %s", r.Method, r.URL.Path, r.RemoteAddr)
			next.ServeHTTP(w, r)
			log.Printf("<-- %s %s en %s", r.Method, r.URL.Path, time.Since(inicio))
		})
	}
*/
func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip, _, err := net.SplitHostPort(r.RemoteAddr)
		if err != nil {
			ip = r.RemoteAddr
		}
		fmt.Printf("IP: %s  %s %s\n", ip, r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
	})
}

func main() {
	const (
		addr          = ":8080"
		topicPath     = "data/tema.json"
		questionsPath = "data/preguntas.json"
		versePath     = "data/versiculo.json"
		prayerPath    = "data/oracion.json"
		ChallengePath = "data/reto.json"
		audioJSONPath = "data/audio.json"
		audioFilePath = "data/audio.m4a"
		helpPath      = "data/ayuda.json"
		awardsPath    = "data/premios.json"
		donationPath  = "data/donaciones.json"
		teachPath     = "data/ensenanzas.json"
		ministryPath  = "data/ministerio.json"
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

	mux.HandleFunc("/api/v1/versiculo_del_dia", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[VerseResponse](versePath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_verse_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/oracion_modelo", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[PrayerResponse](prayerPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_prayer_model",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/reto_del_dia", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[ChallengeResponse](ChallengePath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_challenge_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/ayuda", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[HelpResponse](helpPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_help_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/premios", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[AwardsResponse](awardsPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_award_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/donations", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[DonationsResponse](donationPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_donations_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/ensenanzas", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[TeachingsResponse](teachPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_teachings_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/ministerio", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[MinisteryResponse](ministryPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_ministery_daily",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	mux.HandleFunc("/api/v1/Mensaje_audible", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}

		qs, err := readJSONFile[MessageAuditionResponse](audioJSONPath)
		if err != nil {
			writeJSON(w, http.StatusInternalServerError, ErrorResponse{
				Error:   "failed_to_read_audtion",
				Details: err.Error(),
			})
			return
		}

		writeJSON(w, http.StatusOK, qs)
	})

	/* ------------------------------------------------------------------------------------------

	---------------------------------------------------------------------------------------------------- */
	mux.HandleFunc("/api/v1/Mensaje_audible/archivo", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			writeJSON(w, http.StatusMethodNotAllowed, ErrorResponse{Error: "method_not_allowed"})
			return
		}
		w.Header().Set("Content-Type", "audio/mp4")
		http.ServeFile(w, r, audioFilePath)
	})

	srv := &http.Server{
		Addr: addr,
		//Handler:           mux,// Hernando se cambia para revisar log de la conexion
		Handler:           logRequests(mux),
		ReadHeaderTimeout: 5 * time.Second,
	}
	// Servir archivos estáticos (imágenes) desde ./static
	mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	fmt.Printf("API listening on http://0.0.0.0%s\n", addr)

	addrs, err := net.InterfaceAddrs()
	if err != nil {
		fmt.Println("no se pudieron leer las interfaces:", err)
	} else {
		for _, a := range addrs {
			ipnet, ok := a.(*net.IPNet)
			if ok && !ipnet.IP.IsLoopback() && ipnet.IP.To4() != nil {
				fmt.Printf("IP del servidor: %s  -> http://%s%s\n", ipnet.IP, ipnet.IP, addr)
			}
		}
	}

	fmt.Printf("inicio 6 nov")

	log.Fatal(srv.ListenAndServe())
}
