# Fase 3 — Roteiro manual e rubrica manual-first

Os três fluxos, passo a passo, com o que o tester vê **na versão limpa** e
**na versão com o bug** (L4, C3, P2). A coluna "limpo" vem dos roteiros
executados à mão em 2026-05-25 (`e2e-manual/E2E-01`, `E2E-02`, `E2E-03`,
Web/Chrome); a coluna "com bug" vem da aplicação de cada bug no AVD em
2026-09-28/29 (`README.md`, "Aplicação dos bugs"). Este documento é a
**rubrica**: cada teste gerado numa rodada com bug é codificado contra a
linha do passo em que o sintoma aparece, não contra a saída do `flutter test`
sozinha.

Dados de partida das rodadas (seed): usuário `tester@sintonize.test` /
`senha123`, com `nome = 'tester sintonize'` e `generos_favoritos = ['rock',
'pop']`; 5 músicas em `musica`. Os roteiros de maio usaram uma conta criada
no próprio E2E-01, no Firebase real; aqui tudo é emulador.

## Rubrica de codificação (rodadas com bug)

Aplicar ao **estado final arquivado** da rodada, olhando a saída do `flutter
test`, o código do teste, a resposta do modelo e o print da falha. Um código
por rodada; a iteração em que ele se define vai no template.

| Código | Definição | Como se reconhece |
|---|---|---|
| **Capturou** | O teste falha **por causa do sintoma** do bug: uma asserção (ou uma exceção não tratada) no ponto do sintoma, com a mensagem apontando para ele. | Saída vermelha no passo do sintoma; a asserção que falhou é sobre o que a coluna "com bug" descreve (ex.: esperava `TelaInicialScreen` / esperava o nome na saudação / `RangeError` na lista). |
| **Caracterizou com alerta** | O modelo **descreveu o sintoma como possível defeito do app** — (B) no reparo, ou comentário na geração (C) — independentemente de o teste final estar verde ou vermelho. | Resposta do modelo com a classificação (B) ou com um comentário explícito sobre o comportamento divergente, coerente com a coluna "com bug". Se além disso o teste falha no sintoma, o código é **Capturou** (é o mais forte); "Caracterizou" fica para quando o alerta existe mas o teste não falha ali. |
| **Viu sem asserção** | O teste **passa pelo ponto do sintoma** (chega à tela, executa o passo) mas **não afirma nada** sobre o que a coluna "com bug" descreve; fica verde ou falha por outro motivo. | O caminho do teste inclui o passo do sintoma; nenhuma asserção cobre o elemento afetado (a tela de destino, o texto da saudação, a lista de músicas). O print, se houver, mostra o sintoma. |
| **Canonizou** | O teste **afirma o comportamento com bug como esperado**: a asserção foi escrita ou ajustada (tipicamente num reparo classificado (A)) para o sintoma, e passa. | Asserção que espera `CadastroScreen` após login, o e-mail na saudação, ou trata a exceção da lista como esperada; ou reparo (A) que enfraqueceu/trocou a asserção até o teste ficar verde no app com bug. |
| **Não viu** | O teste **não chega ao ponto do sintoma**: não compila, falha antes (ambiente, navegação, outro erro), ou não cobre o caminho. | Saída vermelha antes do passo do sintoma, ou verde sem passar por ele. Registrar o motivo (não compilou / falha de ambiente / caminho não coberto). |

Regras de desempate:

- Capturou > Caracterizou com alerta > Canonizou > Viu sem asserção > Não viu,
  quando mais de um se aplica. Exceção: **Canonizou** prevalece sobre
  **Caracterizou** se o modelo alertou numa iteração e depois ajustou a
  asserção ao bug para passar — o estado final é o que conta.
- Falha de ambiente antes do sintoma é **Não viu**, com o motivo; não é
  penalidade de estratégia, mas também não é detecção.
- A mesma rubrica se aplica ao teste de referência: L4 → Capturou, C3 →
  Capturou, P2 → Capturou (saída com arquivo:linha). É o teto de comparação.

## Fluxo 1 — Login (E2E-02; bug L4 = `login.dart:36`, `TelaInicialScreen()` → `CadastroScreen()`)

Pré-condição: usuário existente (seed). Caminho: boas-vindas → "Login" → LoginScreen.

| # | Passo do tester | O que vê — limpo | O que vê — com L4 |
|---|---|---|---|
| 1 | Abrir o app e tocar em "Login" | LoginScreen: campos E-mail e Senha, botão "Entrar" | igual |
| 2 | Preencher e-mail válido (`tester@sintonize.test`) | campo aceita | igual |
| 3 | Preencher senha correta (`senha123`) | campo aceita, oculto | igual |
| 4 | Tocar em "Entrar" | autentica; navega | autentica; navega |
| **5** | **Verificar a tela de destino** | **TelaInicialScreen**: card com "Tester Sintonize, essa é a nossa recomendação de música para você!", card de música, barra inferior com "Minha Conta" | **CadastroScreen**: formulário de cadastro vazio (Nome, Data de Nascimento, E-mail, Senha…), botão "Cadastrar", link "Já tem uma conta? Faça login". Nenhuma mensagem de erro. O usuário **está** autenticado no Auth. |
| E1 | "Entrar" com campos vazios | "Por favor, insira seu e-mail" / "Por favor, insira sua senha" | igual |
| E2 | "Entrar" com e-mail inválido | "Por favor, insira um e-mail válido" | igual |
| E3 | "Entrar" com senha < 6 caracteres | "A senha deve ter pelo menos 6 caracteres" | igual |
| E4 | "Entrar" com senha errada | SnackBar vermelha "Senha incorreta. Certifique-se de que está digitando a senha corretamente." (Auth emulator devolve `wrong-password`; em produção, `invalid-credential` → "As credenciais fornecidas são inválidas…") | igual |

**Ponto do sintoma: passo 5.** Só o caminho de sucesso muda; E1–E4 são
idênticos nas duas versões. Um teste que só cobre erros é **Não viu**.
Referência: `login_flow_test` 5/5 → 4/5, `não apareceu em 20s: TelaInicialScreen`.

## Fluxo 2 — Cadastro (E2E-01; bug C3 = `cadastro.dart:149`, `'nome': _nomeController.text` → `_emailController.text`)

Pré-condição: e-mail ainda não cadastrado. Caminho: boas-vindas → "Cadastro" → CadastroScreen → GenerosCadastroScreen → TelaInicialScreen.

| # | Passo do tester | O que vê — limpo | O que vê — com C3 |
|---|---|---|---|
| 1–2 | Abrir o app e tocar em "Cadastro" | CadastroScreen com Nome, Data de Nascimento, E-mail, Senha, Confirmar Senha, CEP, Rua, Número, Bairro, Cidade, Estado | igual |
| 3 | Nome (ex.: "João Silva") | aceita | igual |
| 4 | Data de nascimento (`01012000` → formatador põe as barras) | aceita | igual |
| 5 | E-mail válido e único | aceita | igual |
| 6–7 | Senha e confirmação (≥ 6, iguais) | aceitam, ocultos | igual |
| 8 | CEP válido (`01310100` → `01310-100`) | ViaCEP preenche Rua, Bairro, Cidade ("São Paulo"), Estado ("SP") — rede externa real | igual |
| 9 | Número | aceita | igual |
| 10 | Rolar e tocar em "Cadastrar" | cria conta no Auth e o doc `usuarios/{uid}`; navega para GenerosCadastroScreen | igual na tela; **o doc gravado tem `nome` = o e-mail** (invisível aqui) |
| 11 | Ver a lista de gêneros | Rock, Pop, Jazz, Blues, Hip-Hop, Reggae, Country, com switches | igual |
| 12 | Ligar ao menos um gênero | switch ligado | igual |
| 13 | Tocar em "Confirmar" | grava `generos_favoritos`; navega para TelaInicialScreen | igual |
| **14** | **Verificar a TelaInicialScreen** | card com **"João Silva, essa é a nossa recomendação de música para você!"** e a música recomendada | card com **"Joao@…, essa é a nossa recomendação…"** — o e-mail digitado, com a primeira letra em maiúscula (`_formatName`), no lugar do nome. Em "Minha Conta": **"Bem-vindo(a), joao@…!"**. O resto da tela é normal. |
| E1 | "Cadastrar" com nome com números | "O nome não pode conter números ou caracteres especiais" | igual |
| E2 | E-mail inválido | "E-mail inválido" | igual |
| E3 | Senha < 6 | "A senha deve ter pelo menos 6 caracteres" | igual |
| E4 | Senhas diferentes | "As senhas não coincidem" | igual |
| E5 | CEP inválido | "CEP inválido. Formato correto: XXXXX-XXX" | igual |
| E6 | "Confirmar" sem gênero | SnackBar "Selecione pelo menos um gênero musical!" | igual |

**Ponto do sintoma: passo 14** (e, fora da tela, o campo `nome` do documento
no passo 10). Todo o formulário e a tela de gêneros são idênticos; o sintoma
só aparece **depois** de o fluxo inteiro ter dado certo. Um teste que termina
na GenerosCadastroScreen, ou que chega à TelaInicialScreen e só verifica o
tipo da tela, é **Viu sem asserção**. Referência: `cadastro_flow_test` 6/6 →
5/6, `não apareceu em 20s: … João Silva, essa é a nossa recomendação de`;
uma segunda asserção (`doc['nome']`) existia e nunca rodou.

## Fluxo 3 — Criar playlist (E2E-03; bug P2 = `criar_playlist.dart:165`, `itemCount: _musicasFiltradas.length` → `length + 1`)

Pré-condição: autenticado (seed). Caminho: boas-vindas → "Login" → TelaInicialScreen → "Minha Conta" → UsuarioScreen → "Criar Playlist" → CriarPlaylistScreen.

| # | Passo do tester | O que vê — limpo | O que vê — com P2 |
|---|---|---|---|
| 1 | Na TelaInicialScreen, "Minha Conta" na barra inferior | UsuarioScreen: "Bem-vindo(a), tester sintonize!", item "Criar Playlist", lista de playlists (ou "Você ainda não criou nenhuma playlist.") | igual |
| 2 | Tocar em "Criar Playlist" | CriarPlaylistScreen: "Criando Playlist", campo "Nome da Playlist", campo "Pesquisar Música ou Artista", lista | igual até a lista carregar |
| **3** | **Aguardar a lista de músicas** | 5 cards: "Bohemian Rhapsody - Queen", "Billie Jean - Michael Jackson", "Take Five - Dave Brubeck", "The Thrill Is Gone - B.b. King", "One Love - Bob Marley", cada um com o ícone de checkbox vazio | os 5 cards **e, no fim da lista, um bloco vermelho de erro** (build de debug) com o texto do `RangeError`: "Invalid value: Not in inclusive range 0..4: 5". Em release, um retângulo cinza. Os 5 cards continuam funcionando. |
| 4 | Preencher "Nome da Playlist" | aceita | igual |
| **5** | **Pesquisar (ex.: "queen")** | lista filtra para 1 card | 1 card **e o bloco vermelho** de novo, agora "Only valid value is 0: 1" — o erro acompanha qualquer tamanho de lista |
| 6 | Limpar a pesquisa e marcar uma música pelo ícone | ícone vira check_box preenchido | igual (com o bloco vermelho no fim) |
| 7 | Tocar em "Salvar Playlist" | grava em `playlists`; volta para a UsuarioScreen (pop) | igual — salvar **funciona** |
| 8 | Verificar a playlist na lista | card com o nome e "1 músicas" na UsuarioScreen (o roteiro de maio dizia "TelaInicialScreen"; o app volta para a UsuarioScreen) | igual |
| E1 | "Salvar Playlist" sem nome | SnackBar "Nome da playlist é obrigatório" | igual |

**Ponto do sintoma: passo 3 (e 5).** Diferente de L4 e C3, o sintoma está
**no meio** do fluxo e é visual: o fluxo inteiro ainda completa. Um tester
manual não deixa de ver o bloco vermelho; um teste automatizado, em compensação,
**não precisa de asserção** para pegá-lo — a exceção no `build` é reportada como
falha do teste em curso, com arquivo:linha. Por isso, em P2, **Viu sem
asserção** é quase impossível (o `RangeError` derruba o teste) e **Canonizou**
só ocorre se o teste engolir a exceção de propósito. Referência:
`playlist_flow_test` 4/4 → 0/4, `RangeError (length): Invalid value: Not in
inclusive range 0..4: 5`, stack em `criar_playlist.dart:167`.

## Diferença entre os três, para a análise

| | L4 (login) | C3 (cadastro) | P2 (playlist) |
|---|---|---|---|
| Tipo | SILENT | SILENT | CRASH |
| Onde o sintoma aparece | no fim (tela de destino errada) | no fim, e só no texto de um card | no meio, visual, sem impedir o fluxo |
| O tester manual vê sem procurar? | sim (tela inteira diferente) | só se ler a saudação | sim (bloco vermelho) |
| O teste precisa de asserção específica? | sim (tipo da tela de destino) | sim (texto da saudação ou campo do doc) | não (exceção no build) |
| Referência: testes derrubados | 1 de 5 | 1 de 6 | 4 de 4 |
| Referência: a saída diz o sintoma? | não | não | sim, com arquivo:linha |
