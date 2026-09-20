# Template de Documentação por Rodada — Fase 2 / Réplica Gemini

Use este template para CADA rodada da réplica com Gemini. Campos marcados
com ★ são novos em relação ao template da Fase 1 e relacionam-se ao prompt
de reparo revisado (autoclassificação do modelo). Campos marcados com ✦ são
novos **nesta réplica** e existem para rastrear a versão do modelo servido
sem login — ver `fase2-gemini/README.md`, seção "Por que os dois campos ✦".

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
| **LLM utilizado** | Gemini |
| **Versão do modelo** | (versão adotada como oficial para esta rodada — conciliar os dois campos ✦ abaixo) |
| **✦ Modelo declarado pelo Gemini** | [colar a resposta LITERAL do modelo à pergunta feita no início da sessão — não parafrasear; se recusar ou não souber, registrar isso] |
| **✦ Verificação externa da versão** | [qual modelo é servido sem login nesta data, segundo fonte externa — URL + data de consulta + o que a fonte afirma; se não houver fonte, escrever "não verificável em AAAA-MM-DD"] |
| **Data de acesso** | AAAA-MM-DD |
| **Conversa nova?** | Sim (cada rodada em conversa limpa) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | X.X.X (rodar `flutter --version` e anotar) |

**✦ Como preencher os dois campos de versão.** No início de cada sessão,
antes de colar o prompt da rodada, pergunte ao modelo qual versão ele é e
registre a resposta **literal** em "Modelo declarado pelo Gemini". Em
seguida, confira por fonte externa (changelog/blog oficial, página de
status do produto, imprensa técnica) qual modelo está sendo servido sem
login naquela data e registre em "Verificação externa da versão". Os dois
campos são independentes e podem divergir — quando divergirem, **registre
a divergência, não a resolva**: a autodeclaração de um modelo sobre a
própria identidade não é evidência confiável.

---

## Prompt Enviado

```
[COLAR O PROMPT EXATO AQUI — conforme o arquivo FASE2-<ID>-<ESTRATÉGIA>.md]
```

---

## Resposta do LLM

```
[COLAR A RESPOSTA COMPLETA DO GEMINI AQUI — incluindo análise, código e explicações]
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
- **★ Autoclassificação do modelo:** (A) — teste incorreto / (B) — bug real exposto / (C) — bug identificado espontaneamente na geração inicial / [não declarada]
- **Resultado após correção:** Passou / Falhou

### Iteração 2 (se necessário)

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar]
- **Resposta do LLM:** [colar]
- **★ Autoclassificação do modelo:** (A) / (B) / (C) / [não declarada]
- **Resultado após correção:** Passou / Falhou

### Iteração 3 (máximo)

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar]
- **Resposta do LLM:** [colar]
- **★ Autoclassificação do modelo:** (A) / (B) / (C) / [não declarada]
- **Resultado após correção:** Passou / Falhou

**Nota sobre (C):** (C) não é uma classificação de reparo — é usada quando o
modelo reconheceu e se ajustou ao comportamento real (incluindo o bug) já na
geração inicial do teste, sem que nenhuma falha tenha ocorrido e sem passar
pelo ciclo de reparo. Nesse caso não há "Iteração" a preencher para o bug em
questão; registre (C) e a evidência (o trecho da resposta de geração inicial
em que o modelo comenta/trata o comportamento divergente) diretamente no
campo "★ Autoclassificação do modelo" da tabela de Análise de
Autoclassificação abaixo, referenciando a resposta do LLM na seção
"Resposta do LLM" em vez de uma iteração de reparo.

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) — o modelo entendeu como erro no teste / (B) — o modelo sinalizou possível bug na aplicação / (C) — bug identificado espontaneamente na geração inicial, sem falha nem reparo / Não declarada (modelo não usou o esquema) |
| **★ Classificação humana (auditoria)** | Erro de teste / Bug real exposto / Erro de geração / Limitação de testabilidade / Ambíguo / Falha de ambiente / Bug capturado sem necessidade de reparo (C) |
| **★ Concordância** | Sim / Não / N/A (repair não foi necessário e o bug não foi capturado) |
| **★ Observações** | [descrever divergências, casos limítrofes, ou comentários do modelo relevantes para a análise] |

**Definição de (C):**

> (C) Bug identificado espontaneamente na geração inicial — o modelo
> reconheceu e se ajustou ao comportamento real (incluindo o bug) já ao
> gerar o teste pela primeira vez, sem que nenhuma falha tenha ocorrido e
> sem passar pelo ciclo de reparo. Não há, nesse caso, uma resposta de
> reparo para extrair a autoclassificação — a evidência de (C) é a
> observação, na resposta de geração inicial, de que o modelo comentou ou
> tratou explicitamente o comportamento divergente do esperado.

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
