# Relatório formal de bugs — Sintonize (Fases 2 e 3) — v2, 2026-10-07

Três grupos: **A** bugs plantados (9), **B** defeitos reais não plantados expostos pelo estudo (5), **C** limitações de testabilidade que os modelos classificaram como (B) mas não são defeitos. Linhas de código referem-se ao `lib/` limpo (`ccae44a`, byte-idêntico ao HEAD de `main`), confirmadas por leitura do código em 2026-10-07.

Codificação de detecção: Capturou > Caracterizou c/ alerta > Viu sem asserção > Canonizou > Não viu (Fase 2); Fase 3 mapeada pela nota de equivalência. ChatGPT na Fase 2 = reparo fixo (15 reexecutadas em 2026-09-24).

---

## A. Bugs plantados

| ID | Nível | Arquivo:linha | Alteração (1 linha) | Tipo | Sintoma observável | Alcançável por |
|---|---|---|---|---|---|---|
| U-CRASH | Unitário | `lib/utils/validators.dart:162` | remove `if (word.isEmpty) return word;` em `capitalize` | CRASH | `capitalize('hello  world')` → `RangeError` | **só unitário**: nenhuma tela chama `Validators.capitalize` (cada tela tem cópia privada; `mapa.dart:115` tem a guarda) |
| U-SILENT | Unitário | `validators.dart:117` | `value.length < 6` → `< 7` em `validateSenha` | SILENT | senha de 6 caracteres recusada com mensagem "pelo menos 6" | **só unitário**: `login.dart:153` e `cadastro.dart:286` têm validadores de senha inline próprios |
| W-CRASH | Widget | `lib/criar_playlist.dart:57` (`_filterMusicas`) | `musica['artist_name']?.toLowerCase() ?? ''` → `musica['artist_name'].toLowerCase()` | CRASH | `NoSuchMethodError` ao digitar na busca se algum doc não tiver `artist_name` | widget/integração/E2E, **só com documento sem `artist_name`** (o seed da Fase 3 tem o campo em todos) |
| W-SILENT | Widget | `lib/login.dart:40–43` | troca as mensagens de `user-not-found` e `wrong-password` | SILENT | senha errada → "Usuário não encontrado"; e-mail inexistente → "Senha incorreta" | widget, integração, E2E |
| I-CRASH | Integração | `lib/generos-cadastro.dart:33–34` (`_salvarGeneros`) | `currentUser!.uid` fora do `try`, sem guarda | CRASH | null-check falha ao confirmar gêneros sem usuário autenticado | integração com `signedIn: false`; **não** em E2E (após `createUser` o usuário existe) |
| I-SILENT | Integração | `lib/criar_playlist.dart:241` (`_salvarPlaylist`) | `'nome': _playlistName` → `'nome': 'Nova Playlist'` | SILENT | playlist salva com nome fixo; aparece em Minha Conta como "Nova Playlist" | integração, E2E |
| L4 | E2E | `lib/login.dart:36` | `TelaInicialScreen()` → `CadastroScreen()` no `pushReplacement` | SILENT | login correto abre a tela de Cadastro | widget (com mock de Auth), integração, E2E |
| C3 | E2E | `lib/cadastro.dart:149` | `_nomeController` → `_emailController` ao gravar `nome` | SILENT | saudação da tela inicial mostra o e-mail; `usuarios/{uid}.nome` = e-mail | integração (doc gravado), E2E (saudação) |
| P2 | E2E | `lib/criar_playlist.dart:165` (`itemCount`) | `length` → `length + 1` | CRASH | bloco vermelho (`RangeError`) no fim da lista de músicas | widget, integração, E2E |

### Detecção por bug (modelo × estratégia; passando/falhando no estado final)

| Bug | ChatGPT ZS · FS · COT | Gemini ZS · FS · COT |
|---|---|---|
| U-CRASH | Caracterizou (12/0) · **Capturou** (5/1) · Caracterizou (12/0) | Caracterizou (11/0) · Viu s/ asserção (6/0) · Caracterizou (10/0) |
| U-SILENT | Caracterizou ×3 (12/0, 6/0, 14/0) | Caracterizou ×3 (7/0, 5/0, 8/0) |
| W-CRASH | Não viu ×3 (14/0, 0/10 n.c., 20/1) | Não viu ×3 (5/0, 3/2 n.c., 9/0) |
| W-SILENT | Caracterizou ×3 (7/1, 0/9 n.c., 0/20 n.c.) | Canonizou ×3 (10/1, 9/0, 9/1) |
| I-CRASH | Viu s/ asserção (1/5) · Não viu (2/1) · Canonizou (2/12) | Não viu (1/4) · Não viu (1/3) · Canonizou (2/4) |
| I-SILENT | Caracterizou (2/0) · Caracterizou (0/2 n.c.) · Canonizou (4/0) | Viu s/ asserção (2/0) · Viu s/ asserção (0/2 n.c.) · Canonizou (4/0) |
| L4 | **Capturou ×3** (4/1, 1/1, 6/1) | **Capturou ×3** (4/1, 1/1, 5/1) |
| C3 | Não viu (3/1) · Não viu (0/1) · sem dado | Não viu (1/2) · **Capturou** (0/1) · Não viu (5/0, chegou sem afirmar) |
| P2 | sem dado · **Capturou** (0/1) · Não viu (não compila) | **Capturou ×3** (0/2, 0/1, 0/4) |

n.c. = arquivo final não compila. REEXEC (fora das 60): ChatGPT capturou o I-CRASH em ZS_REEXEC e COT_REEXEC com o prompt corrigido; Gemini não.

### Leitura por bug

- **U-CRASH / U-SILENT:** vistos por todos; quase sempre *caracterizados* (teste passa fixando o bug, resposta avisa). O único Capturou da Fase 2 (ChatGPT U-CRASH-FS) veio de um teste que falhou e foi mantido.
- **W-CRASH:** 0/6 — nenhum teste de busca usou documento sem `artist_name`. É o bug que mede cobertura de dado, não de código.
- **W-SILENT:** divisor entre modelos — ChatGPT disse "as mensagens parecem invertidas" em 10/12 respostas; Gemini nunca; os dois fixaram o par trocado.
- **I-CRASH:** 0/6 capturado nas originais (material do prompt divergente); em COT os dois modelos viram o `currentUser!.uid` fora do `try` e fixaram a exceção como esperada (canonizaram); capturado só nas REEXEC do ChatGPT.
- **I-SILENT:** COT canonizou nos dois (ChatGPT ainda acrescentou `isNot(nome digitado)`).
- **L4:** 6/6 — basta afirmar o tipo da tela de destino. Nenhum reparo (A) retirou essa asserção.
- **C3:** 1/5 com dado — só a FS do Gemini afirmou `dados['nome']`. Três rodadas caíram antes do sintoma por "nome com dígito" — regra presente no `cadastro.dart` do prompt, ignorada pelo modelo. Gemini COT chegou à saudação e afirmou o trecho sem o nome.
- **P2:** 4/4 das que chegaram à lista (a 5ª com dado, ChatGPT COT, não compilou); CRASH entrega arquivo:linha sem asserção.

---

## B. Defeitos reais, não plantados

| # | Local | Defeito | Como se manifesta | Quem apontou | Status |
|---|---|---|---|---|---|
| R1 | `lib/utils/validators.dart:145–151` — `formatName`; **mais 6 cópias privadas com o mesmo defeito** (`criar_playlist.dart:62`, `adicionar-musica.dart:57`, `detalhesplaylist.dart:70`, `perfil-sintonizado.dart:34`, `pesquisa-direta.dart:41`, `tela-inicial.dart:145`), alimentadas por `track_name`/`artist_name` do Firestore | `word[0]` sem guarda para palavra vazia (`split(' ')` com espaço duplo ou nas pontas) | `RangeError` | Fase 1 (origem); Fase 2 ChatGPT: ZS/COT caracterizaram c/ alerta, FS só em prosa; Gemini: ZS e COT detectaram e canonizaram (asserções exigem `throwsA(isA<RangeError>())`), FS só em prosa | **Não corrigido**: `main` e `ccae44a` idênticos, sem a guarda |
| R2 | `lib/criar_playlist.dart:168–170` (`build` da lista) | `musica['artist_name'] ?? 'Desconhecido'` é código morto: `DocumentSnapshot[]` lança `StateError` se o campo não existe, antes do `??`; `track_name` nem tem guarda | um doc sem `artist_name` derruba a lista inteira | ChatGPT WIDGET-FS-03 (Fase 2), (B) em 2 iterações, mantido | Não corrigido. Confirmado no `cloud_firestore` 5.6.4: `DocumentSnapshot[]` → `get()` → `StateError('field … does not exist')` (`platform_interface_document_snapshot.dart:92`); `fake_cloud_firestore` 3.1.0 idem. O `?? 'Desconhecido'` nunca executa. A guarda do `_filterMusicas` (`:57`, `?.toLowerCase() ?? ''`) tem o mesmo problema |
| R3 | `lib/tela-inicial.dart:161` | `setState()` após `dispose()` — callback assíncrono sem `mounted` | "setState() called after dispose()" ao navegar durante a busca de recomendações | Gemini FS-01, FS-02, COT-01 (diagnóstico exato, (B) correto); ChatGPT FS-01, ZS-01 | Não corrigido |
| R4 | `lib/criar_playlist.dart:38–48` (`_fetchMusicas`; `setState` em `:41`, `catch` em `:46–48`) | `setState` após `await … get()` sem `mounted`; `catch (e)` engole a exceção e só faz `print` — sem feedback ao usuário | linha "Erro ao buscar músicas: setState() called after dispose()" sem stack trace — um defeito de tratamento de erro escondendo outro | ChatGPT COT-03 (reparo 3, (B) com `if (!mounted) return;`, causa pelo efeito) e P2-COT (reparo 2); Gemini não viu | Não corrigido |

| R5 | `lib/utils/validators.dart:105` — `validateEmailLogin`; **idêntico no inline de `login.dart:124`** | `RegExp(r'^[^@]+@[^@]+\.[^@]+')` tem `^` mas não `$`, e `[^@]+` aceita espaço | aceita `'a@b.com x'`, `' a@b.com'` e `'a@b.com@c'` como e-mail válido | ChatGPT UNIT-COT-06: escreveu o teste "e-mail com espaços antes/depois (sem trim)" afirmando `isNull` com o comentário "regex ainda considera válido porque não há trim" — **canonizou** o defeito; a rodada fechou com um (B) sobre outro teste (18/1) | Não corrigido |

---

## C. Limitações de testabilidade (não são defeitos)

| # | Local | O que é | Efeito nas rodadas |
|---|---|---|---|
| T1 | `lib/tela-inicial.dart` (e `usuario.dart`) | `FirebaseAuth.instance` / `FirebaseFirestore.instance` estáticos, sem injeção | Fase 2: (B) ou "limitação" em 9 rodadas Gemini e ≥ 8 ChatGPT; fluxo de sucesso do login não isolável em widget/integração. Some no E2E. |
| T2 | `lib/cadastro.dart:448–450` — dropdown de Estado | `DropdownButton` fechado monta os 27 itens num `IndexedStack` com `Visibility(maintainSize…)`: o finder acha o `Text('PE')` invisível e o toque não passa no hit test; aberto, o menu é `ListView` lazy e o 17º item fica na borda/fora do viewport (Offset y≈848, com teclado aberto). Comportamento do Flutter 3.41.6, não do app | ChatGPT I-CRASH REEXEC ×3 (Fase 2); Gemini C3-COT reparo 1 (Fase 3) |
| T3 | `lib/cadastro.dart` — ViaCEP | chamada HTTP real, sem injeção | widget/integração: `CadastroScreen` não compila ou falha (WIDGET-COT-01, INT-FS-02); E2E: SnackBar "CEP não encontrado" antes da do Auth |
| T4 | Protocolo FS | caminho de import não fornecido | 4 (ChatGPT) + 5 (Gemini) rodadas FS sem compilar na Fase 2 |

---

## Totais para o texto

- Bugs plantados: 9 (6 Fase 2 + 3 Fase 3). Capturados pelo menos uma vez: 5 (U-CRASH, L4, C3, P2 nos dois; U-CRASH só ChatGPT). Nunca vistos por ninguém: 1 (W-CRASH).
- Defeitos reais: 5 confirmados no código (R1–R5). Diagnosticados corretamente por pelo menos um modelo: R1, R2, R3; R4 só pelo efeito (ChatGPT); R5 visto e canonizado (ChatGPT escreveu o teste que documenta o comportamento errado como esperado). R1 e R5 estão duplicados em cópias privadas nas telas (6 e 1), o que os torna alcançáveis por widget/E2E mesmo sem `validators.dart`.
- Casos catalogados no estudo: 9 plantados + 5 reais = **14** (o acordo com o orientador falava em 7 = 6 + formatName; a Fase 3 e os achados R2–R5 ampliam).
