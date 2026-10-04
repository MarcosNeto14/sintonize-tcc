# FASE3-E2E-ZS-02_cadastroFlow — tentativas interrompidas pelo serviço (não são rodadas)

Tentativas de 2026-10-03, todas deslogadas, conversa nova cada uma, com o
prompt `prompts_prontos/zero-shot/FASE3-E2E-ZS-02_cadastroFlow.md` colado sem
alteração (50.404 caracteres; sha256 do arquivo `ba091a05d54d5b3a…`, igual a
`_sha256.txt`). Em cada uma, o ChatGPT devolveu só um parágrafo de preâmbulo,
sem nenhum código, e a página registrou na região de status (aria-live) a
mensagem **"Chat interrompido inesperadamente"**. É o próprio serviço
declarando a interrupção. Por isso cada uma é tratada como **ocorrência de
serviço**, como a tentativa de 2026-10-02 da ZS-01 ("O ChatGPT está com
problemas temporários") e a WIDGET-ZS-03 da réplica Gemini. Não contam como
rodada nem como dado do modelo.

| Tentativa | Hora (local) | Envio | Conversa | Resposta | Evidência |
|---|---|---|---|---|---|
| 1 | 23:22 | automatizado (Claude in Chrome); editor conferido por DOM: 50.404 | `chatgpt.com/uc/6ac1b87f-ce30-83ea-907a-8fea1373341a` | 287 caracteres, só preâmbulo | `evidencias/chatgpt/2026-10-03_ZS-02_tentativa1_chat-interrompido.jpg`; texto em `FASE3-E2E-ZS-02_cadastroFlow_TENTATIVA-1_transcricao/` |
| 2 | ~23:28 | **manual, pelo autor** (a colagem automatizada parou de funcionar) | `chatgpt.com/uc/6ac1b98f-43e4-83ea-bb4b-8c580eb7a1fb` | 289 caracteres, só preâmbulo | `evidencias/chatgpt/2026-10-03_ZS-02_tentativa2_chat-interrompido.jpg`; texto em `FASE3-E2E-ZS-02_cadastroFlow_TENTATIVA-2_transcricao/` |

A tentativa 2 descarta a automação como causa: o envio foi à mão e o
resultado se repetiu. O prompt da ZS-02 (50.404 caracteres) é maior que o da
ZS-01 (33.976), que funcionou na mesma noite. Mas na verificação de
infraestrutura de 2026-10-02 o FS-03, o maior prompt, foi aceito e respondido
por inteiro no ChatGPT deslogado. O tamanho, sozinho, não explica.
