# Fase 2 — Réplica com Gemini

Réplica das rodadas da Fase 2 trocando o LLM de ChatGPT para Gemini. Tudo o
mais é mantido idêntico: mesmos alvos, mesmos bugs plantados, mesmas três
estratégias de prompt, mesmo protocolo de reparo (máx. 3 iterações com
autoclassificação A/B/C), mesma execução em sessão sem login. **A única
variável que muda é o modelo.**

Os artefatos do ChatGPT em `fase2/` são o grupo de comparação e
**permanecem intocados**. Nada nesta pasta altera `fase2/`, `prompts/`,
`results/` ou `analise/`.

## Status

**Nenhuma das 60 rodadas executada.** Esta pasta contém a infraestrutura:
prompts copiados, template de documentação e o mapeamento de estado de
código. A submissão dos prompts continua manual.

Uma rodada foi executada em 2026-09-21 sob a condição antiga (sem login) e
**descartada**; está preservada em `piloto-flash-lite/`, fora da contagem.

## ⚠ Mudança de condição — 2026-09-21: sessão COM login, fixada em 3.6 Flash

A condição "sessão sem login", herdada da Fase 2, **foi abandonada nesta
réplica**. Motivo:

Sem login, o seletor do app Gemini **trava em 3.5 Flash Lite** — o tier mais
barato — com 3.6 Flash e 3.1 Pro atrás de login (print em
`evidencias/2026-09-21_gemini_seletor_modelo_sem_login.png`). A Fase 2
deslogada, no ChatGPT, recebeu GPT-5.5/5.6, o topo do que era servido.

"Sem login" nunca foi o controle de fato — era um **proxy para "tier gratuito
padrão"**. No ChatGPT o proxy funcionou; no Gemini ele aponta para outro
lugar. Mantida a condição, a réplica compararia o carro-chefe de um contra o
modelo mais fraco do outro: uma variável não controlada, na direção oposta à
que a réplica quer medir.

**Regra a partir de agora, uniforme para as 60 rodadas:**

1. Sessão **com login**.
2. Modelo **fixado em 3.6 Flash** no seletor, antes de colar o prompt.
3. **Print do seletor por sessão**, arquivado em `evidencias/`.

Consequência positiva: os dois campos ✦ deixam de depender de autodeclaração.
O seletor nomeia o modelo, o print é a evidência, e uma troca silenciosa no
meio do estudo — o incidente GPT-5.5→5.6 da Fase 2 — passa a ser detectável
sessão a sessão.

O desvio a registrar na redação é a sessão logada. Ele é menor que o desvio
que evita.

## Estrutura

```
fase2-gemini/
├── README.md                              (este arquivo)
├── Template_Documentacao_Rodada_Fase2.md  (template + 2 campos novos ✦)
├── prompts_prontos/                       (cópia byte-idêntica de fase2/prompts_prontos/)
├── rodadas/{unit,widget,integration}/     (documentação por rodada — vazio)
└── resultados/{unit,widget,integration}/{zero-shot,few-shot,cot}/
                                           (saídas de flutter test — vazio)
```

---

## Prompts — cópia literal

Os 68 arquivos de `fase2/prompts_prontos/` foram copiados **sem alteração de
um único byte**. Verificado de duas formas: `diff -r` recursivo (sem
diferenças) e `sha256sum` arquivo a arquivo (68/68 idênticos).

### As 60 rodadas em escopo

| Bloco | Rodadas | Onde |
|---|---|---|
| Piloto — bugs plantados | 18 | `prompts_prontos/FASE2-{U,W,I}{CRASH,SILENT}-{ZS,FS,COT}.md` |
| Unitário — alvos limpos | 24 | `prompts_prontos/unit/{zero-shot,few-shot,cot}/` |
| Widget — alvos limpos | 9 | `prompts_prontos/widget/{zero-shot,few-shot,cot}/` |
| Integração — alvos limpos | 9 | `prompts_prontos/integration/{zero-shot,few-shot,cot}/` |
| **Total** | **60** | |

Mesma contagem da Fase 2, bloco a bloco.

### Mais 4 reexecuções, fora da contagem de 60

Quatro rodadas do piloto (W-SILENT-FS e I-CRASH-{ZS,FS,COT}) foram executadas
**duas vezes** com o ChatGPT: uma com o prompt original, que tinha defeitos de
material de apoio, e uma com o prompt corrigido em `FASE2--REEXEC.md`. Os
defeitos eram um exemplo few-shot usando `MockFirebaseAuth(authExceptions:)` —
API inexistente em `firebase_auth_mocks` 0.14.2 — e descrições de tela
divergentes do app real (`SwitchListTile` que não existe; `CadastroScreen`
descrita com 4 campos quando tem 10).

Para que a comparação cubra os dois estados, **o Gemini recebe ambas as
versões**: 64 sessões no total. As 4 reexecuções ficam **fora da manchete de
60**, exatamente como a Fase 2 trata as suas — ver `CLAUDE.md`.

### Fora da contagem

Os 4 arquivos restantes foram copiados junto para a pasta ser autocontida,
mas não são rodadas:

- `prompts_prontos/_fora-de-escopo/` — 6 prompts (`validateSenha` e
  `capitalize` × 3 estratégias) + 1 README. Saíram do grupo limpo na revisão
  de escopo de 2026-09-03; as duas funções já têm dado próprio como alvos do
  U-SILENT e do U-CRASH. Ver o README daquela pasta.

### Desvios preservados de propósito

Estes desvios existiram na execução com ChatGPT e foram mantidos verbatim —
se o ChatGPT recebeu a ajuda, o Gemini também recebe:

- **Caminho de import.** Seis prompts trazem, **dentro do corpo enviado ao
  modelo**, a linha informando `import 'package:sintonize/criar_playlist.dart';`:
  as 3 rodadas de `CriarPlaylistScreen` (widget) e as 3 de `playlistFlow`
  (integração). Os prompts de W-CRASH-{ZS,COT} e I-SILENT-{ZS,COT} do piloto
  também a trazem. A ajuda foi introduzida porque `CriarPlaylistScreen` teve
  0% de aprovação nas 3 estratégias da Fase 1, por alucinação de caminho de
  import.
- **Instrução de reparo revisada** (dois caminhos + autoclassificação A/B) —
  idêntica em todos os prompts.
- **Exemplos de few-shot** — idênticos, inclusive onde contêm APIs
  inexistentes (ver a nota sobre as reexecuções acima).

### Menção a "ChatGPT" nos arquivos copiados

Cada prompt traz uma linha de instrução ao operador:

```
## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)
```

Ela fica **acima** do separador `---` que delimita o prompt, ou seja, **não faz
parte do texto enviado ao modelo**. É a única menção a ChatGPT/GPT em todo o
conjunto — uma por arquivo de rodada, mais quatro em `FASE2--REEXEC.md`. Foi
mantida verbatim, conforme a instrução de não adaptar nada. Ao operar, leia-a
como "colar no Gemini".

---

## Mapeamento rodada ↔ estado do código

Cada bloco exige um estado específico do código. **Confira o estado antes de
rodar `flutter test`** — foi exatamente esse controle que falhou uma vez na
execução com ChatGPT (nota de incidente de 2026-09-03 em
`fase2/propostas_bugs_fase2.md`).

| Bloco | Rodadas | Branch |
|---|---|---|
| Piloto — bugs plantados | 18 (+4 reexecuções) | `fase2-gemini-piloto` |
| Unitário — alvos limpos | 24 | `fase2-alvos-limpos` |
| Widget — alvos limpos | 9 | `fase2-alvos-limpos` |
| Integração — alvos limpos | 9 | `fase2-alvos-limpos` |

### Bloco 1 — piloto, 18 rodadas (+4 reexecuções) em `fase2-gemini-piloto`

**Atenção: não use `fase2-prep`.** Os 6 bugs plantados **não estão todos
ativos em nenhuma ponta de branch**. U-CRASH, U-SILENT e W-SILENT já foram
revertidos na própria `fase2-prep`; W-CRASH, I-CRASH e I-SILENT foram
revertidos em `fase2-alvos-limpos`. Um `checkout fase2-prep` hoje entrega 3
dos 6 bugs já revertidos.

O único estado com os **6 bugs simultaneamente ativos** é o commit `295fa34`.
A branch `fase2-gemini-piloto` foi criada a partir dele exatamente para isso:

```bash
git checkout fase2-gemini-piloto
```

| Rodadas | Bug | Arquivo | Defeito |
|---|---|---|---|
| `FASE2-UCRASH-{ZS,FS,COT}` | U-CRASH | `lib/utils/validators.dart` | `capitalize` sem a guarda `if (word.isEmpty)` |
| `FASE2-USILENT-{ZS,FS,COT}` | U-SILENT | `lib/utils/validators.dart` | `validateSenha` com `value.length < 7` |
| `FASE2-WCRASH-{ZS,FS,COT}` | W-CRASH | `lib/criar_playlist.dart` | `_filterMusicas` acessa `artist_name` sem null-safety |
| `FASE2-WSILENT-{ZS,FS,COT}` | W-SILENT | `lib/login.dart` | mensagens de `user-not-found` e `wrong-password` trocadas |
| `FASE2-ICRASH-{ZS,FS,COT}` | I-CRASH | `lib/generos-cadastro.dart` | `_salvarGeneros` com `currentUser!.uid` fora do `try` |
| `FASE2-ISILENT-{ZS,FS,COT}` | I-SILENT | `lib/criar_playlist.dart` | `_salvarPlaylist` grava `'Nova Playlist'` hardcoded |
| `FASE2-WSILENT-FS_REEXEC` | W-SILENT | `lib/login.dart` | mesmo bug, prompt corrigido |
| `FASE2-ICRASH-{ZS,FS,COT}_REEXEC` | I-CRASH | `lib/generos-cadastro.dart` | mesmo bug, prompt corrigido |

**Verificação do estado — as 6 linhas devem aparecer antes de qualquer rodada:**

```bash
grep -n "value.length < 7"                    lib/utils/validators.dart   # U-SILENT
grep -c "word.isEmpty"                        lib/utils/validators.dart   # U-CRASH: deve dar 0
grep -n "musica\['artist_name'\].toLowerCase" lib/criar_playlist.dart     # W-CRASH
grep -n "'nome': 'Nova Playlist'"             lib/criar_playlist.dart     # I-SILENT
grep -n "currentUser!.uid"                    lib/generos-cadastro.dart   # I-CRASH
grep -n -A1 "e.code == 'user-not-found'"      lib/login.dart              # W-SILENT
```

No W-SILENT, a linha seguinte ao `user-not-found` deve ser a mensagem de
**senha incorreta** — é essa a troca.

### Blocos 2–4 — 42 rodadas de alvo limpo em `fase2-alvos-limpos`

```bash
git checkout fase2-alvos-limpos
```

| Bloco | Alvos |
|---|---|
| Unitário (24) | `validateNome`, `validateNumero`, `validateCEP`, `validateEmail`, `validateEmailLogin`, `validateEmailEdit`, `formatName`, `validateDate` — × 3 estratégias |
| Widget (9) | `CadastroScreen`, `LoginScreen`, `CriarPlaylistScreen` — × 3 |
| Integração (9) | `loginFlow`, `cadastroFlow`, `playlistFlow` — × 3 |

**Verificação do estado:**

```bash
git diff main -- lib/utils/validators.dart   # deve ser VAZIO
git diff main -- lib/login.dart lib/criar_playlist.dart lib/generos-cadastro.dart
# deve mostrar apenas a injeção de dependência do Firebase, nenhum bug
```

**Por que não `fase2-prep` para o bloco unitário.** Para as 24 rodadas
unitárias, `lib/utils/validators.dart` é byte-idêntico nas duas branches e em
`main` — tecnicamente qualquer uma serviria. Use `fase2-alvos-limpos` mesmo
assim, para que os 42 alvos limpos tenham **uma única resposta**, sem exceção
a memorizar no meio da execução.

### Ressalva — as 3 rodadas de `formatName` não são alvo limpo

`FASE2-UNIT-{ZS,FS,COT}-08_formatName` estão no bloco unitário e rodam em
`fase2-alvos-limpos` como as demais, mas `formatName` **carrega um bug real
pré-existente**: nunca teve a guarda `if (word.isEmpty)` e lança `RangeError`
com espaços múltiplos. Esse bug **não é plantado**, nunca foi revertido, e
existe igualmente em `main`, `fase2-prep` e `fase2-alvos-limpos`. Na análise,
essas 3 rodadas **não contam como alvo limpo**.

A nota de metodologia que registra essa reclassificação está no commit
`54aeeb5`, que **só existe em `fase2-prep`**. Lendo
`fase2/propostas_bugs_fase2.md` a partir de `fase2-alvos-limpos`, a nota não
aparece.

### Commits de referência

| Commit | O que faz |
|---|---|
| `8606311` | injeta W-CRASH em `criar_playlist.dart` |
| `4e1c587` | injeta I-SILENT em `criar_playlist.dart` |
| `380af0a` | injeta W-SILENT em `login.dart` |
| `e1aeef0` | injeta I-CRASH em `generos-cadastro.dart` |
| `4783514` | injeta U-CRASH em `validators.dart` |
| `0ed26ac` | injeta U-SILENT em `validators.dart` |
| **`295fa34`** | **último estado com os 6 bugs ativos — base de `fase2-gemini-piloto`** |
| `8d08ff2` | reverte U-CRASH e U-SILENT (em `fase2-prep`) |
| `b9cd1e1` | reverte W-SILENT (em `fase2-prep`) |
| `03c9bac` | cria `fase2-alvos-limpos` revertendo W-CRASH, I-CRASH e I-SILENT |
| `54aeeb5` | nota de reclassificação de `formatName` (só em `fase2-prep`) |

---

## Por que os dois campos ✦

O template desta pasta acrescenta dois campos de metadados por rodada:

- **✦ Modelo declarado pelo Gemini** — perguntar ao modelo, no início de cada
  sessão, qual versão ele é, e registrar a resposta **literal**.
- **✦ Verificação externa da versão** — confirmar por fonte externa qual
  modelo é servido sem login naquela data.

Eles existem por causa de um problema real da execução com ChatGPT: o modelo
servido sem login **mudou no meio do estudo, sem aviso**, e a mudança
(GPT-5.5 → GPT-5.6) só foi percebida meses depois. Sem registro por sessão,
não há como saber em qual rodada a troca aconteceu, e a comparação entre
estratégias fica contaminada por uma variável não controlada.

Os dois campos são **independentes de propósito**. A autodeclaração de um
modelo sobre a própria identidade não é evidência confiável — na execução com
ChatGPT o modelo se autodeclarou "GPT-5.6 Luna", nome que não corresponde a
nenhuma nomenclatura pública da OpenAI (ver `fase2/rodadas/README.md`).
Quando os dois campos divergirem, **registre a divergência; não a resolva**.

---

## Protocolo por rodada

1. Ativar o estado de código do bloco (`git checkout` conforme o mapeamento) e
   rodar a verificação correspondente.
2. Abrir **conversa nova** no Gemini, **com login**, e **fixar 3.6 Flash** no
   seletor antes de qualquer coisa — uma conversa por rodada, sem contexto
   anterior. Cross-contamination invalida a comparação. Ver a seção de
   mudança de condição acima.
3. **Printar o seletor** com 3.6 Flash ativo e arquivar em `evidencias/`.
   Perguntar a versão do modelo e anotar a resposta **literal** (campo ✦). O
   print é a evidência primária; a autodeclaração é o segundo campo, e as
   duas podem divergir — registre a divergência, não a resolva.
4. Colar o prompt da rodada, do separador `---` em diante, **verbatim**.
5. Salvar o teste gerado, rodar `flutter test` e arquivar a saída em
   `resultados/<nível>/<estratégia>/`.
6. Se falhar: prompt de reparo na **mesma** conversa, **máx. 3 iterações**,
   documentando cada uma e a autoclassificação (A/B/C).
7. Preencher o doc da rodada em `rodadas/<nível>/`, a partir de
   `Template_Documentacao_Rodada_Fase2.md`.

Não edite o teste gerado para fazê-lo passar. Se falha, falha — registre. O
único caminho de mutação permitido é o ciclo de reparo documentado.

### Convenção de nomes das 4 reexecuções

Seguir o que `fase2/` já faz: documentar como rodada **nova**, com sufixo
`_REEXEC` (ex.: `rodadas/integration/FASE2-ICRASH-COT_REEXEC.md`), sem
substituir nem sobrescrever a rodada do prompt original. As duas convivem, e a
comparação entre elas é parte do dado.
