# FASE3-P2-ZS — três tentativas sem código; rodada PENDENTE (decisão do autor)

Rodada 6 do plano (bloco 1 — ZS, ChatGPT, bug P2). Prompt
`prompts_prontos/zero-shot/FASE3-E2E-ZS-03_playlistFlow.md` (55.601
caracteres, o mesmo da ZS-03), colado sem alteração e conferido no editor por
leitura do DOM antes de cada envio. Sessão deslogada, envio automatizado
(Claude in Chrome), autor ausente. Worktree `sintonize-fase3-P2` (`60cbaff`)
pronto; **nenhuma execução foi feita**, porque nenhuma resposta trouxe código.

| Tentativa | Hora (2026-10-04) | Conversa | Resposta | Evidência |
|---|---|---|---|---|
| 1 | 00:48 | `chatgpt.com/uc/6ac1cca6-0854-83ea-a6b7-0e74ea82d1fe` | 194 caracteres: "Vou montar o arquivo completo de teste, incluindo o fluxo feliz e o cenário de nome vazio…" | `evidencias/chatgpt/2026-10-04_P2-ZS_tentativa1_sem-codigo.jpg`; `FASE3-P2-ZS_TENTATIVA-1_transcricao/` |
| 2 | 00:50 | `chatgpt.com/uc/6ac1cd1b-16dc-83ea-90ff-171e4dc2fc3f` | 348 caracteres: "Vou montar o arquivo de teste completo… Há um detalhe importante: como a tela usa `IconButton` para os checkboxes…" | `…_tentativa2_sem-codigo.jpg`; `…_TENTATIVA-2_transcricao/` |
| 3 | 00:52 | `chatgpt.com/uc/6ac1cd89-641c-83ea-a13f-436d136ae66e` | 192 caracteres: "Vou montar o arquivo completo de teste E2E…" | `…_tentativa3_sem-codigo.jpg`; `…_TENTATIVA-3_transcricao/` |

Nas três, a resposta terminou (botões de ação presentes, nenhum indicador de
geração) com um único parágrafo que anuncia o arquivo e não o entrega. É o
mesmo padrão das duas primeiras tentativas da ZS-02. A causa não foi
determinada: a região de status "Chat interrompido inesperadamente" não serve
como prova (aparece também em respostas completas — ver a nota da ZS-02).

**Regra aplicada (README, 2026-10-03):** na 3ª tentativa sem código da mesma
rodada, parar e o autor decide, para não repetir até dar certo. Opções:
(a) tentar de novo mais tarde, em outro horário; (b) mudar a condição de
sessão (logado), pelo critério de saída do `CLAUDE.md`; (c) registrar a
rodada como "geração sem código" (0 testes, sem reparo possível).

## Padrão observado na noite de 2026-10-03/04 (ChatGPT deslogado)

| Prompt (caracteres) | Tentativas | Sem código |
|---|---|---|
| ZS-01 (33.976) — ZS-01 e L4-ZS | 2 | 0 |
| ZS-02 (50.404) — ZS-02 e C3-ZS | 4 | 2 (as 2 primeiras da ZS-02) |
| ZS-03 (55.601) — ZS-03 e P2-ZS | 4 | 3 (as 3 da P2-ZS) |

Todas as respostas sem código vieram com prompts de 50 mil caracteres ou mais;
mas prompts desse tamanho também foram respondidos por inteiro (ZS-02 na 3ª
tentativa, C3-ZS, ZS-03). Na verificação de infraestrutura de 2026-10-02, o
FS-03 (56.878) foi respondido por inteiro. O tamanho aumenta a chance, mas não
determina o resultado.

## Encaminhamento decidido em 2026-10-04 (autor)

O autor vai executar esta rodada **manualmente, em outro momento**. Ordem
combinada:

1. Repetir uma vez, sem mudar nada, em outro horário.
2. Se for a C3-COT e falhar de novo: adotar um filtro determinístico da saída
   do terminal só para reparos acima de um limite de tamanho, escrito no README
   **antes** do uso e válido igual para o Gemini (remove as linhas do
   `pub get` e mantém só a primeira cópia de cada despejo de hit test
   repetido). Na saída da C3-COT (60.660 caracteres) os despejos de hit test
   somam ~16.700, as pilhas ~17.000 e o `pub get` ~3.300. O filtro contraria
   a regra "saída literal" e por isso precisa ser registrado como exceção.
3. Se for a P2-ZS e falhar de novo: o filtro não ajuda (o problema é a
   geração). Escolher entre sessão logada, pelo critério de saída do
   `CLAUDE.md`, e registrar a rodada como "geração sem código".

O prompt de geração **não** será reduzido: é o tratamento do experimento
(sha256 fixo), as 16 rodadas fechadas usaram a versão completa e o Gemini
recebe o mesmo texto. O tamanho também não explica sozinho: a ZS-03 usou o
mesmo prompt da P2-ZS e funcionou, e prompts de 55,9 a 56,9 mil caracteres
passaram em FS-03, P2-FS, COT-03 e P2-COT.
