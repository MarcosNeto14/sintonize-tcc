# Template de Documentação por Rodada

Use este template para CADA rodada do experimento (prompt + response + result num único arquivo, ou separados — o importante é que todos os metadados estejam presentes).

---

## Metadados da Rodada

| Campo                    | Valor                                                          |
| ------------------------ | -------------------------------------------------------------- |
| **ID da Rodada**         | UNIT-ZS-01 (formato: NÍVEL-ESTRATÉGIA-NÚMERO)                  |
| **Função testada**       | validateNome                                                   |
| **Arquivo de origem**    | lib/utils/validators.dart (extraída de cadastro.dart)          |
| **Nível da pirâmide**    | Unitário                                                       |
| **Estratégia de prompt** | Zero-shot                                                      |
| **LLM utilizado**        | ChatGPT                                                        |
| **Versão do modelo**     | GPT-4o (ou GPT-4-turbo — verificar no ChatGPT qual está ativo) |
| **Data de acesso**       | 2026-04-20                                                     |
| **Hora de acesso**       | 18:30 (horário de Recife)                                      |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                            |
| **Framework de teste**   | flutter_test                                                   |
| **Versão do Flutter**    | X.X.X (rodar `flutter --version` e anotar)                     |

---

## Prompt Enviado

```
[COLAR O PROMPT EXATO AQUI — incluindo o código da função]
```

---

## Resposta do LLM

```
[COLAR A RESPOSTA COMPLETA DO CHATGPT AQUI — incluindo explicações e código]
```

---

## Resultado da Execução

| Métrica                      | Valor                         |
| ---------------------------- | ----------------------------- |
| **Compilou?**                | Sim / Não                     |
| **Testes gerados**           | X                             |
| **Testes passaram**          | X                             |
| **Testes falharam**          | X                             |
| **Ajuste manual de import?** | Sim / Não (se sim, descrever) |

### Saída do terminal

```
[COLAR A SAÍDA DO `flutter test` AQUI]
```

---

## Iterative Repair Loop (se necessário)

### Iteração 1

- **Motivo da falha:** [descrever o erro]
- **Prompt de correção enviado:** [colar]
- **Resposta do LLM:** [colar]
- **Resultado após correção:** Passou / Falhou

### Iteração 2 (se necessário)

- ...

### Iteração 3 (máximo)

- ...

---


## Convenção de IDs

Para manter consistência, use este padrão nos IDs:

**Nível:**

- UNIT = teste unitário
- WIDGET = widget test
- INT = integration test

**Estratégia:**

- ZS = zero-shot
- FS = few-shot
- COT = chain-of-thought
- MS = multi-step
- CE = context enrichment

**Número:** ordem da tabela do protocolo (01=validateNome, 02=validateSenha, etc.)

**Exemplos:**

- UNIT-ZS-01 = unitário, zero-shot, validateNome
- UNIT-FS-05 = unitário, few-shot, validateEmail
- UNIT-COT-10 = unitário, chain-of-thought, validateDate
- WIDGET-FS-01 = widget test, few-shot, LoginScreen
