import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

class Data {
    long id;
    double val1;
    double val2;

    Data(long id, double val1, double val2) {
        this.id = id;
        this.val1 = val1;
        this.val2 = val2;
    }
}

public class Handler implements RequestHandler<Void, Map<String, Object>> {

    // Para execução local como console (opcional, mas útil)
    public static void main(String[] args) {
        if (System.getenv("AWS_LAMBDA_FUNCTION_NAME") == null) {
            runBenchmark();
        }
    }

    @Override
    public Map<String, Object> handleRequest(Void input, Context context) {
        long[] results = runBenchmark();
        Map<String, Object> response = new HashMap<>();
        response.put("language", "Java");
        response.put("time_ms", results[0]);
        response.put("memory_mb", results[1]);
        return response;
    }

    private static long[] runBenchmark() {
        Runtime runtime = Runtime.getRuntime();
        long m1 = runtime.totalMemory() - runtime.freeMemory();

        long start = System.currentTimeMillis();

        int count = 10_000_000;
        List<Data> list = new ArrayList<>(count);

        for (int i = 0; i < count; i++) {
            list.add(new Data(i, i, i));
        }

        long elapsed = System.currentTimeMillis() - start;
        long m2 = runtime.totalMemory() - runtime.freeMemory();

        long memoryMb = (m2 - m1) / (1024 * 1024);

        System.out.println("Java - Tempo: " + elapsed + "ms");
        System.out.println("Java - Memória Alocada: " + memoryMb + " MB");

        return new long[]{elapsed, memoryMb};
    }
}