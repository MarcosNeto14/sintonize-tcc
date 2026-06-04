# Results — saídas do `flutter test`

Esta pasta consolida a saída do `flutter test` para as 48 rodadas do experimento (30 unitárias + 9 widget + 9 integração), conforme o protocolo descrito em `prompts/README.md`.

## Estrutura

```
results/
├── unit/
│   ├── zero-shot/   UNIT-ZS-01.txt ... UNIT-ZS-10.txt
│   ├── few-shot/    UNIT-FS-01.txt ... UNIT-FS-10.txt
│   └── cot/         UNIT-COT-01.txt ... UNIT-COT-10.txt
├── widget/
│   ├── zero-shot/   WIDGET-ZS-01.txt ... WIDGET-ZS-03.txt
│   ├── few-shot/    WIDGET-FS-01.txt ... WIDGET-FS-03.txt
│   └── cot/         WIDGET-COT-01_iter1.txt ... WIDGET-COT-03_iter3.txt (¹)
└── integration/
    ├── zero-shot/   INT-ZS-01.txt ... INT-ZS-03.txt
    ├── few-shot/    INT-FS-01.txt ... INT-FS-03.txt
    └── cot/         INT-COT-01.txt ... INT-COT-03.txt
```

> (¹) Widget COT usa um arquivo por iteração (`WIDGET-COT-NN_iterK.txt`) porque cada iteração de reparo gerou um arquivo de teste distinto. ZS e FS usam um único arquivo por rodada (estado final).

Cada arquivo `.txt` contém a saída completa do `flutter test` da execução final (pós-repair quando houve reparo). Para rodadas sem reparo, reflete a execução inicial.

## Observações

- **Re-execução pós-reparo:** os logs aqui são o estado **final** dos arquivos de teste (já com os reparos do *Iterative Repair Loop* aplicados). As saídas das execuções iniciais (com falhas) e os prompts de reparo estão preservados nos respectivos docs em `prompts/{nível}/{estratégia}/`.
- **UNIT-ZS-08 e UNIT-FS-08 (`formatName`):** os arquivos de teste foram atualizados retroativamente após UNIT-COT-08 ter modificado a implementação de `Validators.formatName`. Os docs dessas rodadas contêm uma nota metodológica explicando o desvio.
- **WIDGET-COT-03:** resultado final de 12/13 testes passando após 3 iterações de reparo. Rodada executada com GPT-4o (desvio de protocolo; ver nota no doc correspondente).
- **Reproduzir:** rodar `flutter test test/{nível}/<arquivo>_test.dart` em qualquer ambiente com Flutter 3.41.7 (unit/widget) ou Flutter 3.41.6 (integration).
