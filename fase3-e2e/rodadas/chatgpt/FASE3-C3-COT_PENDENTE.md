# FASE3-C3-COT — reparo 1 sem resposta; rodada PENDENTE (decisão do autor)

Rodada 29 do plano (bloco 3 — COT, ChatGPT, bug C3). 2026-10-04 (03:12–03:22),
segunda máquina, sessão deslogada, envio automatizado (Claude in Chrome), autor
ausente. Worktree `sintonize-fase3-C3` (`20edaaa`, C3 ativo em
`cadastro.dart:149`).

## O que foi feito

- **Geração:** prompt `prompts_prontos/cot/FASE3-E2E-COT-02_cadastroFlow.md`
  (corpo de 50.897 caracteres, o mesmo da COT-02), conferido no editor por DOM.
  Conversa `chatgpt.com/uc/6ac1ee82-2ec4-83ea-b681-9bd6bff76219`. Resposta de
  25.906 caracteres, **com fontes externas** ("Documentação Flutter +1"; print
  `evidencias/chatgpt/2026-10-04_FASE3-C3-COT_resposta_iter0_fontes.png`).
  Código salvo sem editar (linhas 99–701 da resposta) em
  `FASE3-C3-COT_transcricao/teste_iter0_geracao.dart` e
  `integration_test/fase3/chatgpt/c3_cot_test.dart`.
- **Iteração 0:** compila; **1/11**. Todos os testes que tocam em "Cadastrar"
  ou no campo de data falham com `would not hit test` (Offset 205.7, 801.0/870.0
  e 63.1, 617.9), o mesmo mecanismo da COT-02. O nome usado é "Usuário E2E", que
  tem dígito e é recusado pelo validador (como em C3-ZS, FS-02 e C3-FS). Saída
  `resultados/chatgpt/FASE3-C3-COT_iter0.txt`; print
  `evidencias/chatgpt/FASE3-C3-COT_iter0.png`.
- **Reparo 1:** o prompt de reparo (template + saída literal) tem **57.926
  caracteres** (`FASE3-C3-COT_transcricao/prompt_reparo_iter1.txt`). Foi
  colado e conferido por DOM, e enviado por volta das 03:18. A mensagem do usuário
  aparece na conversa; **a resposta do modelo veio vazia** (nenhum texto), com
  o status "Chat interrompido inesperadamente" e o botão "Repetir", e o editor
  voltou a conter o prompt. Duas tentativas pelo botão "Repetir" (que regenera
  a resposta para a mesma mensagem, sem duplicá-la) também terminaram vazias.
  Print `evidencias/chatgpt/2026-10-04_FASE3-C3-COT_reparo1_sem_resposta.jpg`.

Diferente da ZS-02 e da P2-ZS, aqui não há nem preâmbulo: o turno do assistente
está vazio. A conversa acumulava ~134 mil caracteres (prompt 50.897 + resposta
24.730 + reparo 57.926) quando falhou. Hipótese não verificada: limite de
contexto da sessão deslogada.

## Regra aplicada

Na 3ª tentativa sem resposta útil da mesma rodada, parar; o autor decide.
Opções: (a) repetir mais tarde na mesma conversa; (b) mudar a condição de
sessão (logado), pelo critério de saída do `CLAUDE.md`; (c) registrar a rodada
com o estado da iteração 0 (1/11; reparo impossível). Codificação manual-first
provisória, só com a iteração 0: **Não viu** — nenhum teste chega a comparar
o campo `nome` gravado no Firestore, porque o toque em "Cadastrar" não acerta o
botão.

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
