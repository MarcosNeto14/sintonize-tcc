# Piloto descartado — Gemini 3.5 Flash Lite (sem login)

**Fora da contagem de 60.** Esta pasta guarda a única rodada executada antes
da revisão da condição experimental, em 2026-09-21, e existe porque o que
aconteceu nela **é dado**, não erro de operação.

## O que foi executado

`FASE2-UCRASH-ZS` (U-CRASH, `Validators.capitalize`, zero-shot), em conversa
nova do app Gemini **sem login**, na branch `fase2-gemini-piloto` com os 6
bugs plantados ativos. Resultado: 9 testes passaram, 1 falhou.

## Por que foi descartada

A réplica pressupõe que **o modelo é a única variável que muda**. A condição
"sessão sem login" foi herdada da Fase 2 como constante do protocolo, mas ela
nunca foi o controle de fato — era um proxy para "tier gratuito padrão".

No ChatGPT o proxy funcionou: deslogado, a Fase 2 recebeu GPT-5.5/5.6, o topo
do que era servido. No Gemini ele aponta para outro lugar: deslogado, o
seletor **trava em 3.5 Flash Lite**, o tier mais barato, com 3.6 Flash e
3.1 Pro atrás de login (print em
`../evidencias/2026-09-21_gemini_seletor_modelo_sem_login.png`).

Mantida a condição, a comparação deixaria de ser "ChatGPT × Gemini" e passaria
a ser "carro-chefe do ChatGPT × modelo mais fraco do Gemini" — uma variável
não controlada, na direção oposta à que a réplica quer medir.

**Decisão (2026-09-21):** as 60 rodadas passam a rodar **com login, fixadas em
3.6 Flash**, com print do seletor por sessão. O desvio é a sessão logada; o
ganho é tier comparável e versão do modelo verificável por evidência de UI,
em vez de autodeclaração. Ver `../README.md`.

## Achado que justifica guardar

**O prompt de reparo verbatim foi recusado.** Colado sem alteração, o
3.5 Flash Lite respondeu:

```
Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho
capacidade de entender e responder a essa questão.
```

Reenviado com uma alteração mínima (uma vírgula a mais), o mesmo modelo
produziu uma análise completa e classificou a falha como **(B)**. Não é
recusa de política — é um modelo pequeno demais engasgando num prompt de
reparo que contém bloco de log. Em rodadas de widget e integração, com
prompts de 200+ linhas, esse modo de falha tenderia a se repetir.

Isso é evidência sobre o que o tier gratuito deslogado do Gemini consegue
fazer, e sustenta a decisão acima.

## Arquivos

| Arquivo | Conteúdo |
|---|---|
| `FASE2-UCRASH-ZS_PILOTO.md` | doc completo da rodada, no template da réplica |
| `ucrash_zs_test.dart` | teste gerado pelo modelo (fora de `test/` de propósito — não deve entrar na suíte) |
| `FASE2-UCRASH-ZS_iter0.txt` | saída de `flutter test` (9 passaram, 1 falhou) |
