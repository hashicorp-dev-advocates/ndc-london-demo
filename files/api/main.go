package main

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"net/http"
	"time"

	"github.com/brianvoe/gofakeit/v6"
	"github.com/nicholasjackson/env"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/hashicorp/go-hclog"
)

var log hclog.Logger
var bind = env.String("BIND_ADDR", false, ":3000", "URL for the payments service")
var payments = env.String("PAYMENTS", false, "http://localhost:9091", "URL for the payments service")
var weather = env.String("WEATHER", false, "http://localhost:9092", "URL for the weather service")
var defaultClient *http.Client

func main() {
	env.Parse()

	log = hclog.New(&hclog.LoggerOptions{
		Level: hclog.Debug,
		Color: hclog.AutoColor,
	})

	defaultClient = &http.Client{
		Transport: &http.Transport{
			DisableKeepAlives: true,
			TLSClientConfig:   &tls.Config{InsecureSkipVerify: true},
		},
		Timeout: 30 * time.Second,
	}

	r := chi.NewRouter()

	r.Use(middleware.Logger)
	r.Get("/v1/weather", doWeather)
	r.Post("/v1/pay", doPay)

	r.Get("/ready", healthHandler)
	r.Get("/health", healthHandler)

	log.Info("Starting server")

	http.ListenAndServe(*bind, r)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

type PaymentRequest struct {
	ID          string  `fake:"{regex:[a-z]{64}}"`
	Name        string  `fake:"{name}"`
	Type        string  `fake:"{creditcardtype}"`
	Number      string  `fake:"{creditcardnumber}"`
	Exp         string  `fake:"{creditcardexp}"`
	CVV         string  `fake:{creditcardcvv}"`
	Amount      float64 `fake:"{price:1,1000}"`
	DateCreated time.Time
}

func doPay(w http.ResponseWriter, r *http.Request) {
	pr := &PaymentRequest{}
	gofakeit.Struct(pr)
	pr.DateCreated = time.Now()

	d, _ := json.Marshal(pr)
	req, _ := http.NewRequest(http.MethodPost, *payments, bytes.NewBuffer(d))

	resp, err := defaultClient.Do(req)
	if err != nil {
		log.Error("Unable to execute request", "error", err)
		http.Error(w, "unable to execute request", http.StatusInternalServerError)
		return
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNotModified {
		log.Error("Expected status 200 or 201, got", "status", resp.StatusCode)
	}

	w.WriteHeader(resp.StatusCode)
}

func doWeather(w http.ResponseWriter, r *http.Request) {
	req, _ := http.NewRequest(http.MethodGet, *weather, nil)

	resp, err := defaultClient.Do(req)
	if err != nil {
		log.Error("Unable to execute request", "error", err)
		http.Error(w, "unable to execute request", http.StatusInternalServerError)
		return
	}

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNotModified {
		log.Error("Expected status 200 or 201, got", "status", resp.StatusCode)
	}

	w.WriteHeader(resp.StatusCode)
}
