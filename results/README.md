# Results — saídas do `flutter test`

Esta pasta consolida a saída do `flutter test` para cada uma das 30 rodadas unitárias do experimento, conforme o protocolo descrito em `prompts/README.md`.

## Estrutura

```
results/
└── unit/
    ├── zero-shot/   UNIT-ZS-01.txt ... UNIT-ZS-10.txt
    ├── few-shot/    UNIT-FS-01.txt ... UNIT-FS-10.txt
    └── cot/         UNIT-COT-01.txt ... UNIT-COT-10.txt
```

Cada arquivo `.txt` contém:

- ID da rodada, função-alvo, estratégia
- Caminho do arquivo de teste executado
- Timestamp ISO-8601 da execução
- Versão do Flutter usada
- Saída completa do `flutter test <arquivo>`

## Observações

- **Re-execução pós-reparo:** os logs aqui são o estado **final** dos arquivos de teste (já com os reparos do *Iterative Repair Loop* aplicados). As saídas das execuções iniciais (com falhas) e os prompts de reparo estão preservados nos respectivos `prompts/unit/{estratégia}/UNIT-*.md`.
- **UNIT-ZS-08 e UNIT-FS-08 (`formatName`):** os arquivos de teste foram atualizados retroativamente após UNIT-COT-08 ter modificado a implementação de `Validators.formatName`. Ver as notas de regressão nos respectivos `.md` em `prompts/`.
- **Reproduzir:** rodar `flutter test test/unit/<arquivo>_test.dart` em qualquer ambiente com o SDK indicado no cabeçalho de cada `.txt`.
