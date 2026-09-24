# Template de Documentação por Rodada — Fase 2 / Reexecução ChatGPT

Use este template para CADA rodada da reexecução com ChatGPT. Os campos marcados
com ★ são novos em relação ao template da Fase 1. Eles se referem ao prompt de
reparo revisado, em que o modelo classifica a própria falha. Os campos marcados
com ✦ rastreiam a versão do modelo servido; ver `fase2-gemini/README.md`, seção
"Por que os dois campos ✦". Os campos marcados com ◆ são novos **nesta
reexecução** e existem para provar que o protocolo de reparo fixo foi seguido.
Ver `fase2-chatgpt-reexec/README.md`.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-ZS (formato: FASE2-\<ID\>-\<ESTRATÉGIA\>[_REEXEC]) |
| **Bug ID** | U-CRASH / U-SILENT / W-CRASH / W-SILENT / I-CRASH / I-SILENT |
| **Função/tela alvo** | capitalize / validateSenha / CriarPlaylistScreen / LoginScreen / GenerosCadastroScreen / CriarPlaylistScreen |
| **Arquivo(s) de origem** | lib/utils/validators.dart |
| **Nível da pirâmide** | Unitário / Widget / Integração |
| **Estratégia de prompt** | Zero-shot / Few-shot / Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | (versão adotada como oficial para esta rodada — conciliar os dois campos ✦ abaixo) |
| **✦ Modelo declarado pelo ChatGPT** | [colar a resposta LITERAL do modelo à pergunta feita no início da sessão — não parafrasear; se recusar ou não souber, registrar isso] |
| **✦ Verificação externa da versão** | [print do seletor/da tela em `evidencias/` + qual modelo é servido nesta data segundo fonte externa — URL + data de consulta + o que a fonte afirma; se não houver fonte, escrever "não verificável em AAAA-MM-DD"] |
| **Modelo servido (fonte externa, URL + data)** | [modelo servido sem login nesta data segundo a fonte — ex.: OpenAI Help Center; colar URL, data de consulta e o trecho literal] |
| **Sessão** | Deslogada |
| **Branch / estado do código** | `fase2-chatgpt-reexec` (lib/ = `fase2-gemini-piloto`), \<bug\> ativo (6 greps conferidos) |
| **Data de acesso** | AAAA-MM-DD |
| **Conversa nova?** | Sim (cada rodada em conversa limpa) — [URL da conversa] |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | X.X.X (rodar `flutter --version` e anotar) |
| **Arquivo de teste** | `test/fase2-chatgpt-reexec/<nível>/<nome>_test.dart` |
| **Saídas arquivadas** | `resultados/<nível>/<ID>_iter<N>[_final].txt` |
| **Modo de execução** | Manual / Automatizado (descrever: quem colou o prompt, como a resposta foi extraída) |
| **Versão do prompt** | Original (`prompts_prontos/FASE2-<ID>-<ESTR>.md`) / Corrigido (`prompts_prontos/FASE2--REEXEC.md`, linhas X–Y) — sem alteração |

**✦ Como preencher os dois campos de versão.** No início de cada sessão,
antes de colar o prompt da rodada, pergunte ao modelo qual versão ele é e
registre a resposta **literal** em "Modelo declarado pelo ChatGPT". Em
seguida, confira por fonte externa (changelog/blog oficial, página de
status do produto, imprensa técnica) qual modelo está sendo servido naquela
data e registre em "Verificação externa da versão", junto com o print. Os dois
campos são independentes e podem divergir — quando divergirem, **registre
a divergência, não a resolva**: a autodeclaração de um modelo sobre a
própria identidade não é evidência confiável.

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — [URL] | Resposta completa / Recusa: "[texto literal]" / Erro de serviço: "[texto literal]" |

Recusa ou erro de serviço: reenviar o prompt **inalterado** em conversa nova e
acrescentar uma linha. Uma tentativa perdida não é iteração de reparo.

---

## Prompt Enviado

```
[COLAR O PROMPT EXATO AQUI — do separador `---` em diante, conforme o arquivo de prompt]
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
| **Iterações de reparo** | 0–3 |
| **Testes passaram (estado final)** | X ou — |
| **Testes falharam (estado final)** | X ou — |
| **◆ Melhor estado intermediário** | X/Y na iteração N, ou "igual ao final". Só registro: o estado final é sempre o da última iteração aplicada, sem reversão |
| **Tentativas de envio até obter resposta** | X (Y recusas, Z erros de serviço) |
| **Bug plantado exercitado?** | Sim / Não |
| **Bug plantado capturado por asserção?** | Sim / Não / Canonizado (o teste exige o comportamento defeituoso) |
| **Bug plantado mencionado na resposta?** | Sim (onde) / Não |

### Saída do terminal

```
[COLAR A SAÍDA DO `flutter test` AQUI]
```

---

## Iterative Repair Loop

**◆ Regra do reparo:** o prompt de reparo é o template fixo do arquivo de prompt,
de "O teste falhou com o seguinte erro:" até "alterar o teste.", com a saída do
terminal colada no lugar indicado. **Nada além disso.** O texto literal enviado
vai obrigatoriamente no Apêndice. É ele que prova que o protocolo foi seguido.

### Iteração 1

- **Motivo da falha:** [descrever o erro]
- **◆ Prompt de reparo enviado (obrigatório):** texto literal no Apêndice, seção "Reparo 1 — prompt enviado". Confirmar: [ ] template fixo + saída do terminal, sem acréscimo
- **Resposta do LLM:** [resumo; integral no Apêndice]
- **★ Autoclassificação do modelo:** (A) — teste incorreto / (B) — bug real exposto / (C) — bug identificado espontaneamente na geração inicial / [não declarada]
- **◆ Opção aplicada:** [arquivo completo / opção nomeada como recomendada pelo modelo: "..." / primeira opção, sem recomendação explícita]
- **Resultado após correção:** Passou / Falhou (X/Y)

### Iteração 2 (se necessário)

- **Motivo da falha:** [descrever o erro]
- **◆ Prompt de reparo enviado (obrigatório):** Apêndice, "Reparo 2 — prompt enviado". [ ] template fixo + saída, sem acréscimo
- **Resposta do LLM:** [resumo]
- **★ Autoclassificação do modelo:** (A) / (B) / (C) / [não declarada]
- **◆ Opção aplicada:** [...]
- **Resultado após correção:** Passou / Falhou (X/Y)

### Iteração 3 (máximo)

- **Motivo da falha:** [descrever o erro]
- **◆ Prompt de reparo enviado (obrigatório):** Apêndice, "Reparo 3 — prompt enviado". [ ] template fixo + saída, sem acréscimo
- **Resposta do LLM:** [resumo]
- **★ Autoclassificação do modelo:** (A) / (B) / (C) / [não declarada]
- **◆ Opção aplicada:** [...]
- **Resultado após correção:** Passou / Falhou (X/Y)

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

## Apêndice — textos literais

### Resposta da geração inicial

```
[resposta integral]
```

### Reparo 1 — prompt enviado

```
[texto LITERAL enviado ao modelo, byte a byte: template fixo + saída do terminal]
```

### Reparo 1 — resposta

```
[resposta integral]
```

### Reparo 2 — prompt enviado

```
[texto literal]
```

### Reparo 2 — resposta

```
[resposta integral]
```

### Reparo 3 — prompt enviado

```
[texto literal]
```

### Reparo 3 — resposta

```
[resposta integral]
```

---

## Convenção de IDs — Fase 2

**Formato:** `FASE2-<BUG_ID>-<ESTRATÉGIA>`, com sufixo `_REEXEC` para as 4 rodadas de prompt corrigido

| Bug ID | Nível | Alvo |
|---|---|---|
| UCRASH | Unitário | capitalize |
| USILENT | Unitário | validateSenha |
| WCRASH | Widget | CriarPlaylistScreen (_filterMusicas) |
| WSILENT | Widget | LoginScreen (login()) |
| ICRASH | Integração | GenerosCadastroScreen (_salvarGeneros) |
| ISILENT | Integração | CriarPlaylistScreen (_salvarPlaylist) |

**Estratégia:** ZS = zero-shot, FS = few-shot, COT = chain-of-thought

**Exemplos:** `FASE2-UCRASH-ZS`, `FASE2-WSILENT-COT`, `FASE2-ICRASH-FS_REEXEC`
