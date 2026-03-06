package main

import (
	"context"
	"fmt"
	"os"
	"runtime"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

type Data struct {
	ID   int64
	Val1 float64
	Val2 float64
}

type Response struct {
	Language string `json:"language"`
	Time     string `json:"time"`
	Memory   uint64 `json:"memory"`
}

func main() {
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") == "" {
		// Execução local
		runBenchmark()
	} else {
		// Execução como Lambda
		lambda.Start(handler)
	}
}

func handler(ctx context.Context) (Response, error) {
	timeStr, memory := runBenchmark()
	return Response{
		Language: "Go",
		Time:     timeStr,
		Memory:   memory,
	}, nil
}

func runBenchmark() (string, uint64) {
	var m1, m2 runtime.MemStats
	runtime.ReadMemStats(&m1)

	start := time.Now()

	count := 10_000_000
	list := make([]Data, count)

	for i := 0; i < count; i++ {
		list[i] = Data{ID: int64(i), Val1: float64(i), Val2: float64(i)}
	}

	elapsed := time.Since(start)
	runtime.ReadMemStats(&m2)

	timeStr := elapsed.String()
	memory := (m2.Alloc - m1.Alloc) / (1024 * 1024)

	fmt.Printf("Go - Tempo: %v\n", timeStr)
	fmt.Printf("Go - Memória Alocada: %v MB\n", memory)

	return timeStr, memory
}
