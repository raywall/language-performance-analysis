
|             | .NET | Go    | Java | Node.JS | Python  |
| ----------- | ---- | ----- | ---- | ------- | ------- |
| **Tempo**   | 45   | 21.80 | 140  | 518.58  | 6120.76 |
| **Memória** | 228  | 228   | 430  | 533.24  | 1367.92 |


```mermaid
--- 
config: 
  xyChart: 
    width: 1200 
    height: 600
    titleFontSize: 30 
    showDataLabel: true
  themeVariables: 
    xyChart: 
      titleColor: "#ff0000" 
---
xychart-beta
    title "Benchmark: Tempo Total de Execução"
    x-axis ["Go", ".NET", "Java", "Node.JS", "Python"]
    y-axis "Tempo (ms)" 0 --> 1400
    bar [228, 228, 430, 533, 1367]
```

```mermaid
--- 
config: 
  xyChart: 
    width: 1200 
    height: 600 
    titleFontSize: 30
    showDataLabel: true
  themeVariables: 
    xyChart: 
      titleColor: "#ff0000" 
---
xychart-beta
    title "Benchmark: Consumo Total de Memória"
    x-axis ["Go", ".NET", "Java", "Node.JS", "Python"]
    y-axis "Memória Alocada (MB)" 0 --> 6500
    bar [21, 45, 140, 548, 6120]
```
# language-performance-analysis
