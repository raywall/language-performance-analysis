using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Amazon.Lambda.Core;
using Amazon.Lambda.RuntimeSupport;
using Amazon.Lambda.Serialization.SystemTextJson;

[assembly: LambdaSerializer(typeof(DefaultLambdaJsonSerializer))]

public struct Data
{
    public long Id { get; set; }
    public double Val1 { get; set; }
    public double Val2 { get; set; }
}

class Program
{
    static async Task Main(string[] args)
    {
        if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable("AWS_LAMBDA_FUNCTION_NAME")))
        {
            // Modo local (console)
            RunBenchmark();
            return;
        }

        // Modo Lambda
        Func<string, ILambdaContext, Task<string>> handler = (input, context) =>
        {
            var (timeMs, memoryMb) = RunBenchmark();
            // Retorna JSON simples – pode ser ajustado para um objeto tipado se preferir
            return Task.FromResult(
                $"{{\"language\": \".NET 10\", \"time_ms\": {timeMs}, \"memory_mb\": {memoryMb}}}"
            );
        };

        await LambdaBootstrapBuilder
            .Create(handler, new DefaultLambdaJsonSerializer())
            .Build()
            .RunAsync();
    }

    private static (long TimeMs, long MemoryMb) RunBenchmark()
    {
        // Força GC para medição mais consistente
        GC.Collect(2, GCCollectionMode.Forced, true, true);
        GC.WaitForPendingFinalizers();
        GC.Collect(2, GCCollectionMode.Forced, true, true);

        long allocBefore = GC.GetTotalAllocatedBytes(true);

        var sw = Stopwatch.StartNew();

        const int count = 10_000_000;
        var list = new Data[count];

        for (int i = 0; i < count; i++)
        {
            list[i] = new Data { Id = i, Val1 = i, Val2 = i };
        }

        // Evita dead code elimination
        if (list[count - 1].Id < 0)
            Console.WriteLine("negative");

        sw.Stop();

        long allocAfter = GC.GetTotalAllocatedBytes(true);

        long timeMs   = sw.ElapsedMilliseconds;
        long memoryMb = (allocAfter - allocBefore) / (1024 * 1024);

        Console.WriteLine($".NET 10 - Tempo: {timeMs} ms");
        Console.WriteLine($".NET 10 - Memória Alocada: {memoryMb} MB");

        return (timeMs, memoryMb);
    }
}