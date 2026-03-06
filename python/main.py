import time
import os
import psutil
import json
import sys

class Data:
    __slots__ = ['id', 'val1', 'val2']
    def __init__(self, id, v1, v2):
        self.id = id
        self.val1 = v1
        self.val2 = v2

def get_mem():
    process = psutil.Process(os.getpid())
    return process.memory_info().rss

def run_benchmark():
    m1 = get_mem()
    start = time.time()

    count = 10_000_000
    lista = [Data(i, float(i), float(i)) for i in range(count)]

    end = time.time()
    m2 = get_mem()

    time_ms = (end - start) * 1000
    memory_mb = (m2 - m1) / 1024 / 1024

    print(f"Python - Tempo: {time_ms:.2f}ms")
    print(f"Python - Memória Alocada: {memory_mb:.2f} MB")

    return time_ms, memory_mb

def lambda_handler(event, context):
    start_time = time.time()  # Estimativa interna de cold start
    time_ms, memory_mb = run_benchmark()
    return {
        'language': 'Python',
        'time': time_ms,
        'memory': memory_mb
    }

if __name__ == "__main__":
    if 'AWS_LAMBDA_FUNCTION_NAME' not in os.environ:
        # Execução local
        run_benchmark()
    # Senão, o runtime Lambda chama lambda_handler