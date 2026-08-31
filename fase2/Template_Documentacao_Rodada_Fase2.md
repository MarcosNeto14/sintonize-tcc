# Template de Documentação por Rodada — Fase 2

Use este template para CADA rodada da Fase 2. Campos marcados com ★ são
novos em relação ao template da Fase 1 e relacionam-se ao prompt de reparo
revisado (autoclassificação do modelo).

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-ZS (formato: FASE2-\<ID\>-\<ESTRATÉGIA\>) |
| **Bug ID** | U-CRASH / U-SILENT / W-CRASH / W-SILENT / I-CRASH / I-SILENT |
| **Função/tela alvo** | capitalize / validateSenha / CriarPlaylistScreen / LoginScreen / GenerosCadastroScreen / CriarPlaylistScreen |
| **Arquivo(s) de origem** | lib/utils/validators.dart |
| **Nível da pirâmide** | Unitário / Widget / Integração |
| **Estratégia de prompt** | Zero-shot / Few-shot / Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 (confirmar no início da conversa) |
| **Data de acesso** | AAAA-MM-DD |
| **Conversa nova?** | Sim (cada rodada em conversa limpa) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | X.X.X (rodar `flutter --version` e anotar) |

---

## Prompt Enviado

```
[COLAR O PROMPT EXATO AQUI — conforme o arquivo FASE2-<ID>-<ESTRATÉGIA>.md]
```

---

## Resposta do LLM

```
[COLAR A RESPOSTA COMPLETA DO CHATGPT AQUI — incluindo análise, código e explicações]
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim / Não |
| **Testes gerados** | X |
| **Testes passaram (1ª execução)** | X |
| **Testes falharam (1ª execução)** | X |
| **Testes passaram (pós-repair)** | X ou — |
| **Testes falharam (pós-repair)** | X ou — |

### Saída do terminal

```
[COLAR A SAÍDA DO `flutter test` AQUI]
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar — conforme seção "Prompt de reparo" do arquivo do prompt]
- **Resposta do LLM:** [colar resposta completa]
- **★ Autoclassificação do modelo:** (A) — teste incorreto / (B) — bug real exposto / [não declarada]
- **Resultado após correção:** Passou / Falhou

### Iteração 2 (se necessário)

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar]
- **Resposta do LLM:** [colar]
- **★ Autoclassificação do modelo:** (A) / (B) / [não declarada]
- **Resultado após correção:** Passou / Falhou

### Iteração 3 (máximo)

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar]
- **Resposta do LLM:** [colar]
- **★ Autoclassificação do modelo:** (A) / (B) / [não declarada]
- **Resultado após correção:** Passou / Falhou

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) — o modelo entendeu como erro no teste / (B) — o modelo sinalizou possível bug na aplicação / Não declarada (modelo não usou o esquema) |
| **★ Classificação humana (auditoria)** | Erro de teste / Bug real exposto / Erro de geração / Limitação de testabilidade / Ambíguo / Falha de ambiente |
| **★ Concordância** | Sim / Não / N/A (repair não foi necessário) |
| **★ Observações** | [descrever divergências, casos limítrofes, ou comentários do modelo relevantes para a análise] |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |

---

## Convenção de IDs — Fase 2

**Formato:** `FASE2-<BUG_ID>-<ESTRATÉGIA>`

| Bug ID | Nível | Alvo |
|---|---|---|
| UCRASH | Unitário | capitalize |
| USILENT | Unitário | validateSenha |
| WCRASH | Widget | CriarPlaylistScreen (_filterMusicas) |
| WSILENT | Widget | LoginScreen (login()) |
| ICRASH | Integração | GenerosCadastroScreen (_salvarGeneros) |
| ISILENT | Integração | CriarPlaylistScreen (_salvarPlaylist) |

**Estratégia:** ZS = zero-shot, FS = few-shot, COT = chain-of-thought

**Exemplos:** `FASE2-UCRASH-ZS`, `FASE2-WSILENT-COT`, `FASE2-ISILENT-FS`
