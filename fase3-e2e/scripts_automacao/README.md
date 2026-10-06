# Scripts de automação das rodadas Gemini (2026-10-06)

Cópia dos scripts usados na máquina original (`DellT4i51`) nas rodadas 20–32,
para continuar em outra máquina. Os caminhos estão fixos para aquela máquina
(`C:\Users\marcos.neto\...`); ajustar antes de usar.

| Script | O que faz |
|---|---|
| `extrai.ps1 <prompt_pronto.md>` | Extrai o prompt (entre o 2º e o 3º `---`), sem CR, e carrega no clipboard. Validado: reproduz os 35.008 caracteres da FS-01. |
| `run.sh <teste> <saida.txt> <print.png>` (com `W=<worktree>`) | Espera os emuladores, roda o `seed_test` no worktree, confere por REST 1 conta / 1 `usuarios` / 5 `musica` e **não executa** se diferente; roda o teste, salva saída e print do AVD; no fim encerra os daemons do Gradle/Kotlin (memória). |
| `reparo.ps1 <saida.txt> <destino.txt> <modelo.txt>` | Monta o prompt de reparo (template fixo + saída literal) a partir de um `prompt_reparo_iter1.txt` existente como modelo; grava e carrega no clipboard. Validado: reproduz byte a byte o `prompt_reparo_iter1.txt` da FS-01. |
| `salva.ps1 <dir> <N> <rótulo> <rodada> <conversa> <teste_no_worktree>` | Grava `iterN_resposta.md` do clipboard (com cabeçalho), recusa se o clipboard tiver sentinela/prompt; extrai o maior bloco que abre em linha ```` ```dart ```` e fecha na próxima linha ```` ``` ````; grava `teste_iterN.dart` e aplica no worktree. **Conferir se o bloco é um teste completo** (quando a resposta é (B) só com trechos do app, não aplicar). |

Procedimento por execução: derrubar e subir os emuladores Firebase (só via
PowerShell nessa máquina), depois `run.sh`. Envio ao Gemini: Ctrl+V no editor,
conferir tamanho/início/fim por JavaScript, clicar na seta; recarregar a
conversa antes de copiar; copiar pelo "Copiar" logo abaixo da última resposta
e conferir o clipboard (sentinela) antes de gravar. Recusa/erro genérico:
botão "Editar" da mensagem, acrescentar " ." e "Atualizar".
