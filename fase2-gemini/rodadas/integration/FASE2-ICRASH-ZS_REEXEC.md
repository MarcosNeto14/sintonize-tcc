# FASE2-ICRASH-ZS_REEXEC — Réplica Gemini

Reexecução **2/4**, fora da contagem de 60. Mesmo bug da rodada 13
(`FASE2-ICRASH-ZS`), com o prompt corrigido de
`prompts_prontos/FASE2--REEXEC.md`: o código real completo de
`lib/cadastro.dart` e `lib/generos-cadastro.dart`, colado verbatim, no lugar
das versões resumidas (que tinham `SwitchListTile` inexistente e um
`CadastroScreen` de 4 campos). Execução automatizada (Claude in Chrome).

**Resultado: rodada não executada — duas recusas ao mesmo prompt.**
Procedimento do README ("Recusas repetidas ao mesmo prompt [...] parar e
documentar em vez de insistir").

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-ZS_REEXEC |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | `GenerosCadastroScreen._salvarGeneros` |
| **Arquivo(s) de origem** | `lib/cadastro.dart`, `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, I-CRASH ativo |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | **Corrigido**, de `prompts_prontos/FASE2--REEXEC.md` (linhas 248-982), sem alteração — 27.337 caracteres |
| **Arquivo de teste** | nenhum — não houve código gerado |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/e252cd80d2f918a3` | **Recusa:** "Não tenho como te ajudar. Sou só um modelo de linguagem e não entendo o que você está me pedindo." |
| 2 | nova — `gemini.google.com/app/b4d3979dc48a1eb0` | **Recusa:** "Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho capacidade de entender e responder a essa questão." |

Nas duas o prompt foi conferido no campo antes do envio (início "Gere um teste
de integração...", fim "...não a uma versão resumida"), e a mensagem enviada
aparece uma única vez na conversa.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Testes gerados** | 0 |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **não obteve** (2 recusas; parado pelo protocolo) |
| **Bug plantado capturado por asserção?** | Não se aplica |
| **Bug plantado mencionado na resposta?** | Não se aplica |

---

## Observações

1. **Primeira recusa repetida da réplica.** Até aqui as recusas foram
   isoladas e a tentativa seguinte, em conversa nova, respondia (rodada 6 e
   a reexecução 1/4, nesta mesma sessão).
2. **O prompt corrigido é o maior do conjunto** — 27 mil caracteres, com as
   duas telas completas. O original da rodada 13, resumido, foi respondido na
   primeira tentativa. Tamanho é uma hipótese, não uma conclusão: o prompt da
   reexecução 1/4 (5,3 mil caracteres) também foi recusado uma vez.
3. **Para a comparação com o ChatGPT:** lá esta reexecução foi respondida e
   executada. O custo de corrigir o material, para o Gemini, foi perder a
   rodada.
