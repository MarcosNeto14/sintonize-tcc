# Prompts da Fase 3 (E2E)

Nove prompts: 3 fluxos (login, cadastro, playlist) × 3 estratégias (ZS, FS,
COT). Cada arquivo serve à rodada limpa e à rodada com bug do fluxo, nos dois
modelos — o prompt é o mesmo nas 4 combinações; o que muda é o `lib/` do
worktree onde o teste gerado roda. **Nenhum prompt menciona bug**, e nenhum
contém material dos testes de `integration_test/_referencia/`.

```
zero-shot/FASE3-E2E-ZS-01_loginFlow.md      few-shot/FASE3-E2E-FS-01_loginFlow.md      cot/FASE3-E2E-COT-01_loginFlow.md
zero-shot/FASE3-E2E-ZS-02_cadastroFlow.md   few-shot/FASE3-E2E-FS-02_cadastroFlow.md   cot/FASE3-E2E-COT-02_cadastroFlow.md
zero-shot/FASE3-E2E-ZS-03_playlistFlow.md   few-shot/FASE3-E2E-FS-03_playlistFlow.md   cot/FASE3-E2E-COT-03_playlistFlow.md
```

## Como foram derivados

Os 9 são gerados por `_gerar_prompts.py` a partir dos prompts de integração
da Fase 2 (`fase2/prompts_prontos/integration/`), e o script é a
especificação exata da derivação. O que se preservou e o que mudou:

| Elemento | Fase 2 (integração, mocks) | Fase 3 (E2E, emuladores) |
|---|---|---|
| Estrutura do arquivo | cabeçalho, notas de protocolo, `---`, prompt, `---`, prompt de reparo | idêntica, incluindo o separador `---` e o prompt de reparo **byte a byte** |
| Descrição do fluxo | parágrafo do prompt ZS | **o mesmo parágrafo, verbatim**, extraído pelo script do arquivo ZS da Fase 2 |
| Bloco de código | telas do fluxo, verbatim, com `// ===== lib/x.dart =====` | mesmo formato; entram todas as telas do caminho a partir do início do app (`lib/main.dart` + as do fluxo), lidas do `lib/` limpo (`ccae44a`) |
| Dependências | lista de mocks (`firebase_auth_mocks`, `fake_cloud_firestore`, `mockito`) | substituída pelo bloco "Ambiente de execução" (abaixo) |
| Requisitos ZS | `testWidgets`, `MaterialApp` com rotas, mocks, cenários, comando, imports | mesma lista, com os itens de mock trocados por app real + helper dos emuladores; cenários de erro restritos aos alcançáveis pela interface |
| Passos COT | 5 passos (analisar, dependências e mocks, navegação com rotas, cenários, escrever) | os mesmos 5 passos; o passo 2 pergunta o que cada tela lê/grava nos emuladores, o passo 3 pede o caminho de navegação a partir da tela de boas-vindas |
| Exemplo FS | um teste de integração de um "fluxo de formulário" com `MockFirebaseAuth`, o mesmo nos 3 prompts | um teste E2E de outro aplicativo, um por prompt, de um fluxo que **não** é alvo (ver abaixo) |

## Bloco fixo "Ambiente de execução"

Uma única string no script, colada depois do bloco de código em todos os 9
prompts. O sha256 do bloco e o de cada arquivo estão em `_sha256.txt`. O
bloco contém, e só isso:

1. o que é o teste (app real no AVD `emulator-5554`, emuladores Auth/Firestore em `10.0.2.2`, sem mocks);
2. o conteúdo verbatim de `integration_test/firebase_test_helper.dart` e a instrução de chamar `setupFirebaseEmulators()` em `setUpAll()`, com o import relativo;
3. o estado dos emuladores antes de cada execução: usuário `tester@sintonize.test` / `senha123` (doc `usuarios/{uid}` com `nome` e `generos_favoritos`) e as 5 músicas de `musica`;
4. a navegação a partir da tela de boas-vindas (botões "Login" e "Cadastro", e o caminho de cada fluxo);
5. onde o arquivo é salvo e o comando de execução.

Não há adaptação por modelo. Se um prompt precisar de correção, o arquivo
corrigido recebe sufixo (como `_REEXEC` na Fase 2), o original fica, e o
script é atualizado para gerar os dois.

## Como os exemplos few-shot foram escolhidos

Seleção dos exemplos few-shot registrada conforme a diretriz 5.3 de Baltes
et al. (2026), que exige explicitar o critério de escolha dos exemplos:

1. **Mesma tecnologia do alvo.** Cada exemplo é um teste `integration_test`
   que roda um app real em emulador, chama um helper de emuladores em
   `setUpAll()`, navega pela interface e espera respostas de rede com um
   laço de `pump` — exatamente o que a rodada pede. Na Fase 2 o exemplo era
   um teste com mocks, também a tecnologia do alvo de lá.
2. **Fluxo que não é alvo e não compartilha o sintoma.** login → exemplo de
   **logout**; cadastro → **edição de perfil**; playlist → **recuperação de
   senha**. Nenhum dos três é login, cadastro ou criar playlist; nenhum passa
   pela tela de destino do login, pela saudação da tela inicial nem por uma
   lista de músicas, que são onde L4, C3 e P2 aparecem. Assim o exemplo não
   ensina a asserção que pegaria o bug.
3. **Outro aplicativo.** Os exemplos usam identificadores fictícios
   (`package:meu_app/...`, `App`, `ContaScreen`, `EditarPerfilScreen`,
   `RecuperarSenhaScreen`, botões "Acessar"/"Sair"/"Salvar"/"Enviar") para
   não vazar nomes reais do Sintonize nem trechos da implementação de
   referência. O helper importado no exemplo tem o mesmo nome do real,
   porque o prompt manda usá-lo.
4. **Mesma forma nos três.** Mesmo cabeçalho, mesmo `setUpAll`, mesmo
   auxiliar `esperar`, login pela interface antes do fluxo (exceto
   recuperação de senha, que é acessível sem login), 1 ou 2 `testWidgets`
   (sucesso + um erro de validação), 40–60 linhas. A diferença entre os
   três prompts FS é só o fluxo do exemplo.
5. **Sem menção a bug, a asserção diagnóstica nem a armadilha de
   dispositivo.** Os exemplos não fecham teclado, não esperam a tela de
   origem sumir nem verificam hit test — as armadilhas encontradas ao
   escrever a referência ficam fora do prompt, para não dar à FS uma
   vantagem que ZS e COT não têm. **Uma exceção, declarada:** o auxiliar
   `esperar` (laço de `pump` até o finder aparecer) é a única prática
   aprendida ao escrever a referência que os exemplos few-shot carregam.
   ZS e COT não a recebem. É uma assimetria inerente à estratégia — um
   exemplo de teste E2E que espera resposta de rede precisa de alguma
   forma de espera — e fica registrada aqui para ser considerada na
   análise.

## Verificação

```
sha256sum -c fase3-e2e/prompts_prontos/_sha256.txt      # no diretório dos prompts
git diff ccae44a -- lib/                                # tem de ser vazio ao (re)gerar
```

O `_sha256.txt` é o que cada doc de rodada confere no campo "Arquivo do
prompt" do template.

### Tamanho do trecho colado

Medido no trecho entre o segundo e o terceiro `---` de cada arquivo (o que
é colado no modelo), sem os espaços das pontas; palavras separadas por
espaço em branco.

| Fluxo | ZS | FS | COT |
|---|---|---|---|
| 01 login | 33.976 car. / 2.318 pal. / 899 linhas | 35.008 / 2.372 / 943 | 34.484 / 2.413 / 906 |
| 02 cadastro | 50.404 / 3.436 / 1.383 | 52.384 / 3.551 / 1.450 | 50.897 / 3.533 / 1.390 |
| 03 playlist | 55.601 / 3.740 / 1.541 | **56.878 / 3.783 / 1.598** | 55.879 / 3.797 / 1.547 |

O maior é o FS-03 (56.878 caracteres); o COT-03 usado na verificação de
infraestrutura de 2026-09-29 tem 55.879.
