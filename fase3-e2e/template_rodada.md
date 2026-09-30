# Template de Documentação por Rodada — Fase 3 (E2E)

Use este template para CADA rodada da Fase 3, nos dois modelos. É o template
da Fase 2 (campos ★ de autoclassificação) com os campos ✦ de versão da
réplica Gemini e da reexecução ChatGPT, mais o **procedimento operacional**
do E2E, que não existia nas fases anteriores porque os testes rodavam sem
dispositivo.

Regras que não mudam em relação à Fase 2:

- **Conversa nova** por rodada. Nenhum contexto anterior; nenhuma rodada
  reaproveita conversa.
- **Colar o prompt sem alterar.** O que vai para o modelo é tudo entre os
  dois `---` da seção "Prompt" do arquivo em `prompts_prontos/`. A linha
  "colar no modelo da rodada" fica acima do separador e não é enviada.
- **Reparo pelo template fixo, com a saída literal do `flutter test`.** Só o
  prompt de reparo do arquivo, com a saída do terminal colada no lugar
  indicado. Nada mais: nenhum caminho, assinatura, `build()`, dica ou achado de
  rodada anterior. (Foi isso que invalidou 15 rodadas da Fase 2 —
  `fase2/_execucao-assistida/`.)
- **Máximo de 3 iterações de reparo.** O estado arquivado é o da última
  iteração, mesmo que pior; o melhor estado intermediário é registrado no
  campo próprio.
- **Autoclassificação A/B/C** registrada literalmente a cada iteração.
- **Os testes de `integration_test/_referencia/` não entram na conversa**, em
  nenhuma forma.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-ZS-01_loginFlow (limpa) ou FASE3-L4-ZS (com bug) — ver "Convenção de IDs" |
| **Modelo** | ChatGPT / Gemini |
| **Fluxo alvo** | login / cadastro / playlist |
| **Estado do `lib/`** | limpo (`fase3-e2e`, igual a `ccae44a`) / com bug L4 (`eb14334`) / C3 (`20edaaa`) / P2 (`60cbaff`) |
| **Worktree usado** | caminho + `git rev-parse --short HEAD` conferido no momento da execução |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot / Few-shot / Chain-of-Thought |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/<pasta>/FASE3-E2E-<SIGLA>-<NN>_<fluxo>.md` + sha256 conferido contra `prompts_prontos/_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | [resposta LITERAL à pergunta feita no início da sessão, antes de colar o prompt — não parafrasear; se recusar ou não souber, registrar isso] |
| **✦ Verificação externa da versão** | [qual modelo é servido nesta condição de sessão nesta data, segundo fonte externa — URL + data de consulta + o que a fonte afirma; se não houver, "não verificável em AAAA-MM-DD"] |
| **Sessão** | ChatGPT: deslogada (igual às Fases 2 e reexecução). Gemini: logada, conta Pro, modelo fixado no seletor em 3.8 Flash, com print do seletor em `evidencias/` (igual à réplica) |
| **Data de acesso** | AAAA-MM-DD |
| **Conversa nova?** | Sim |
| **Versão do Flutter** | `flutter --version` (esperado 3.41.6 · Dart 3.11.4) |
| **AVD** | `tcc_e2e` (Pixel 6, API 34, google_apis, x86_64) — `adb devices` mostra `emulator-5554 device` |
| **firebase-tools** | `firebase --version` (esperado 15.31.0) |

**✦ Os dois campos de versão são independentes e podem divergir.** Quando
divergirem, registre a divergência, não a resolva. A autodeclaração de um
modelo não é evidência suficiente sozinha.

---

## Procedimento operacional (executar na ordem; marcar cada passo)

Antes da conversa:

- [ ] **Worktree certo para o estado do `lib/`.** Rodada limpa: worktree
      `Desktop/sintonize-fase3` na `fase3-e2e`, com `git diff ccae44a -- lib/`
      vazio. Rodada com bug: worktree próprio no hash do bug, criado uma vez
      (`git worktree add ../sintonize-fase3-L4 eb14334`, idem `-C3 20edaaa`,
      `-P2 60cbaff`), e conferido com `git rev-parse --short HEAD` **na hora**.
      Nunca trocar de branch dentro de um worktree para "ir ao outro estado".
- [ ] **AVD `tcc_e2e` ligado**: `emulator -avd tcc_e2e -no-snapshot-load -no-boot-anim`
      até `adb -s emulator-5554 shell getprop sys.boot_completed` devolver `1`
      (25–132 s).
- [ ] **Emuladores Firebase no ar**, desacoplados do terminal da sessão
      (`Start-Process`/`cmd /c` em segundo plano):
      `firebase emulators:start --only auth,firestore --project sintonize-fa494`
      na raiz do worktree; `curl` em 9099 e 8080 respondendo 200.

Na conversa:

- [ ] Perguntar a versão ao modelo; registrar literal (✦).
- [ ] Colar o prompt exatamente como está entre os `---`.
- [ ] Salvar o código gerado, sem editar, em
      `integration_test/fase3/<modelo>/<arquivo>_test.dart` **do worktree da
      rodada** (nomes na "Convenção de IDs"). Se a resposta vier em mais de um
      bloco de código, registrar como foi montado o arquivo.

A cada execução (geração e cada iteração de reparo):

- [ ] **Seed limpo:** derrubar e subir os emuladores (o Firestore emulator não
      persiste entre reinícios) e rodar
      `flutter test integration_test/seed_test.dart -d emulator-5554` no worktree
      da rodada. Confirmar no Emulator UI (`http://127.0.0.1:4000`) ou pela saída
      do seed que há 1 usuário e 5 músicas e nada mais.
- [ ] **Comando exato**, um `flutter test` por comando (encadear dois travou):
      `flutter test integration_test/fase3/<modelo>/<arquivo>_test.dart -d emulator-5554`
- [ ] Guardar a saída íntegra em
      `fase3-e2e/resultados/<modelo>/<ID>_iter<N>.txt` (`iter0` = geração; o
      último recebe também o sufixo `_final`).
- [ ] **Print da tela do AVD no momento da falha, quando houver:**
      `adb -s emulator-5554 exec-out screencap -p > fase3-e2e/evidencias/<modelo>/<ID>_iter<N>.png`,
      tirado logo após o `flutter test` terminar em falha, com o app ainda na
      tela em que parou. É o que permite comparar com a coluna "o que o tester
      vê" de `roteiro_manual.md`.
- [ ] Se falhou e ainda há iteração: colar **só** o prompt de reparo com a
      saída literal, na mesma conversa.

Depois da rodada:

- [ ] Copiar o arquivo de teste final do worktree da rodada para
      `integration_test/fase3/<modelo>/` do worktree `sintonize-fase3` (é lá que
      se commita; os worktrees dos bugs ficam sempre no hash, sem commits).
- [ ] Preencher este documento em `fase3-e2e/rodadas/<modelo>/<ID>.md` e commitar
      doc + teste + resultados + evidências juntos, na `fase3-e2e`.
- [ ] Rodada com bug: preencher a "Codificação manual-first" abaixo.

---

## Prompt Enviado

```
[COLAR O PROMPT EXATO AQUI — conforme o arquivo em prompts_prontos/]
```

---

## Resposta do LLM

```
[COLAR A RESPOSTA COMPLETA AQUI — incluindo análise, código e explicações]
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim / Não |
| **Testes gerados** | X |
| **Testes passaram (iteração 0)** | X |
| **Testes falharam (iteração 0)** | X |
| **Testes passaram (estado final arquivado)** | X ou — |
| **Testes falharam (estado final arquivado)** | X ou — |
| **Melhor estado intermediário** | X/Y na iteração N (quando o estado final não é o melhor; senão "= final") |
| **Tempo por execução** | Gradle X s + teste Y s, por iteração |
| **Prints tirados** | lista de `evidencias/…png` ou "nenhuma falha em tela" |

### Saída do terminal (iteração 0)

```
[COLAR A SAÍDA DO `flutter test` AQUI]
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar — só o template fixo + saída literal]
- **Resposta do LLM:** [colar resposta completa]
- **★ Autoclassificação do modelo:** (A) — teste incorreto / (B) — bug real exposto / (C) — bug identificado espontaneamente na geração inicial / [não declarada]
- **Resultado após correção:** X/Y — Passou / Falhou
- **Print:** `evidencias/…` ou —

### Iteração 2 (se necessário)

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar]
- **Resposta do LLM:** [colar]
- **★ Autoclassificação do modelo:** (A) / (B) / (C) / [não declarada]
- **Resultado após correção:** X/Y — Passou / Falhou
- **Print:** —

### Iteração 3 (máximo)

- **Motivo da falha:** [descrever o erro]
- **Prompt de reparo enviado:** [colar]
- **Resposta do LLM:** [colar]
- **★ Autoclassificação do modelo:** (A) / (B) / (C) / [não declarada]
- **Resultado após correção:** X/Y — Passou / Falhou
- **Print:** —

**Nota sobre (C):** (C) não é uma classificação de reparo — é usada quando o
modelo reconheceu e se ajustou ao comportamento real (incluindo o bug) já na
geração inicial do teste, sem que nenhuma falha tenha ocorrido e sem passar
pelo ciclo de reparo. Registre (C) e a evidência (o trecho da resposta de
geração inicial em que o modelo comenta/trata o comportamento divergente) na
tabela de Análise de Autoclassificação, referenciando a seção "Resposta do
LLM" em vez de uma iteração.

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) / (B) / (C) / Não declarada |
| **★ Classificação humana (auditoria)** | Erro de teste / Bug real exposto / Erro de geração / Limitação de testabilidade / Ambíguo / Falha de ambiente / Bug capturado sem necessidade de reparo (C) |
| **★ Concordância** | Sim / Não / N/A |
| **★ Observações** | [divergências, casos limítrofes, comentários do modelo relevantes] |

**Referência de categorias (classificação humana — mesmas das Fases 1 e 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | AVD, emuladores, Gradle, rede (ViaCEP), teclado/viewport, transição de rota — ver `analise/custo_e_referencia.md`, "Armadilhas" |

**Falha de ambiente em E2E merece cuidado:** as armadilhas do dispositivo
(teclado aberto encolhendo o viewport, tela de destino encontrada durante a
transição, `pumpAndSettle` que nunca assenta com `CircularProgressIndicator`)
derrubam testes corretos. Uma falha dessas **não** é "Erro de teste" nem "Bug
real exposto"; é ambiente, e conta como tal nas duas condições (limpa e com
bug).

---

## Codificação manual-first (só rodadas com bug — rubrica em `roteiro_manual.md`)

| Campo | Valor |
|---|---|
| **Bug da rodada** | L4 / C3 / P2 |
| **Sintoma manual de referência** | [copiar a linha "com bug" do passo correspondente em `roteiro_manual.md`] |
| **O teste chegou ao ponto do sintoma?** | Sim / Não (falhou antes / não compilou / não cobre o caminho) |
| **Código** | Capturou / Caracterizou com alerta / Viu sem asserção / Canonizou / Não viu |
| **Evidência** | [trecho da saída, da asserção ou da resposta do modelo que sustenta o código; print, se houver] |
| **Iteração em que o código se define** | 0 / 1 / 2 / 3 |

---

## Convenção de IDs — Fase 3

Rodadas **limpas** (lib/ igual a `ccae44a`): `FASE3-E2E-<SIGLA>-<NN>_<fluxo>`,
com NN/fluxo = `01_loginFlow`, `02_cadastroFlow`, `03_playlistFlow`.

Rodadas **com bug**: `FASE3-<BUG>-<SIGLA>`, com BUG = `L4` (login,
`eb14334`), `C3` (cadastro, `20edaaa`), `P2` (playlist, `60cbaff`).

SIGLA = `ZS`, `FS`, `COT`. O modelo não entra no ID; entra no caminho.

Arquivos:

```
fase3-e2e/rodadas/<modelo>/<ID>.md
fase3-e2e/resultados/<modelo>/<ID>_iter<N>[_final].txt
fase3-e2e/evidencias/<modelo>/<ID>_iter<N>.png              # prints de falha
integration_test/fase3/<modelo>/<fluxo>_<sigla>_test.dart    # limpa: login_zs_test.dart
integration_test/fase3/<modelo>/<bug>_<sigla>_test.dart      # bug:   l4_zs_test.dart
```

com `<modelo>` = `chatgpt` ou `gemini`, e o prompt usado sempre o mesmo
arquivo em `prompts_prontos/`, nas duas condições e nos dois modelos.
