# INT-FS-01 — Fluxo Login — Few-shot

## Metadados

| Campo                    | Valor                                                          |
| ------------------------ | -------------------------------------------------------------- |
| **ID da Rodada**         | INT-FS-01                                                      |
| **Fluxo testado**        | Login (LoginScreen → TelaInicialScreen)                        |
| **Arquivos envolvidos**  | lib/login.dart, lib/tela-inicial.dart                         |
| **Nível da pirâmide**    | Integration test                                               |
| **Estratégia de prompt** | Few-shot                                                       |
| **LLM utilizado**        | ChatGPT                                                        |
| **Versão do modelo**     | [preencher]                                                    |
| **Data de acesso**       | [preencher]                                                    |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                            |
| **Framework de teste**   | flutter_test                                                   |
| **Versão do Flutter**    | [rodar `flutter --version` e anotar]                           |

---

## Prompt Enviado

```
[COLAR O PROMPT EXATO AQUI — montado a partir de PROMPT_TEMPLATE_INTEGRATION.md (estratégia Few-shot), com o código completo de lib/login.dart e lib/tela-inicial.dart substituídos nos marcadores]
```

---

## Resposta do LLM

```
[COLAR A RESPOSTA COMPLETA DO CHATGPT AQUI — incluindo análise e código gerado]
```

---

## Resultado da Execução

| Métrica             | Valor     |
| ------------------- | --------- |
| **Compilou?**       | Sim / Não |
| **Testes gerados**  | X         |
| **Testes passaram** | X         |
| **Testes falharam** | X         |

### Saída do terminal

```
[COLAR A SAÍDA DO `flutter test test/integration/login_fs_test.dart` AQUI]
```

---

## Iterative Repair Loop

### Iteração 1 (se necessário)

- **Motivo da falha:** [descrever o erro]
- **Prompt de correção enviado:** [colar]
- **Resposta do LLM:** [colar]
- **Resultado após correção:** Passou / Falhou

### Iteração 2 (se necessário)

- ...

### Iteração 3 (máximo)

- ...
