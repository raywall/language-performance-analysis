const { performance } = require('perf_hooks');

function Data(id, val1, val2) {
    this.id = id;
    this.val1 = val1;
    this.val2 = val2;
}

function runBenchmark() {
    const m1 = process.memoryUsage().heapUsed;
    const start = performance.now();

    const count = 10_000_000;
    const list = new Array(count);

    for (let i = 0; i < count; i++) {
        list[i] = new Data(i, i, i);
    }

    const end = performance.now();
    const m2 = process.memoryUsage().heapUsed;

    const timeMs = (end - start).toFixed(2);
    const memoryMb = ((m2 - m1) / 1024 / 1024).toFixed(2);

    console.log(`Node.js - Tempo: ${timeMs}ms`);
    console.log(`Node.js - Memória Alocada: ${memoryMb} MB`);

    return { time: timeMs, memory: memoryMb };
}

if (process.env.AWS_LAMBDA_FUNCTION_NAME) {
    // Execução como Lambda
    exports.handler = async (event, context) => {
        const startTime = performance.now(); // Estimativa interna
        const results = runBenchmark();
        return {
            language: 'Node.js',
            time: results.time,
            memory: results.memory
        };
    };
} else {
    // Execução local como console
    runBenchmark();
}