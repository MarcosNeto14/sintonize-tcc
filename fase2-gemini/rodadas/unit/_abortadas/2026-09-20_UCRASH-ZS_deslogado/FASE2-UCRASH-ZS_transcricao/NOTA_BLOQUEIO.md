# Bloqueio — FASE2-UCRASH-ZS (réplica Gemini)

**Data:** 2026-09-20
**Conversa da rodada:** https://gemini.google.com/app/7a3a9178bd280ebf
**Estado:** geração concluída; **ciclo de reparo bloqueado pela plataforma**.

## O que aconteceu

A geração inicial funcionou. O Gemini respondeu com um artefato **Canvas**
("Testes Unitários - Validators Capitalize") em vez de um bloco de código
inline. O arquivo foi recuperado pelo botão "Baixar" e está em
`canvas_gerado_verbatim.dart`.

`flutter test` na branch `fase2-gemini-piloto` (worktree, 6 bugs ativos):
**8 testes, 6 passaram, 2 falharam** — saída em
`fase2-gemini/resultados/unit/zero-shot/FASE2-UCRASH-ZS_iter0.txt`.

Como houve falha, o protocolo exige o prompt de reparo na **mesma** conversa.
Toda tentativa de enviá-lo falha com a mensagem de erro do Gemini:

```
Algo deu errado (1184)
```

O POST para `.../BardFrontendService/StreamGenerate` retorna **HTTP 200** —
o erro vem no payload, não no transporte. Reenvios (5 tentativas, por clique
em coordenada, por `ref` do botão e por Enter no composer) falham igual.

## Diagnóstico

Testes feitos em abas separadas, na mesma sessão anônima e deslogada:

1. O **mesmo** prompt de reparo, enviado como **primeira** mensagem de uma
   conversa nova, é aceito e respondido normalmente
   (`https://gemini.google.com/app/b787a8c23b422516`). Logo **não é** tamanho
   da mensagem, conteúdo, filtro nem cota global.
2. Nessa conversa de diagnóstico o Gemini respondeu **inline, sem Canvas**, e
   um follow-up curto ("ok") foi aceito normalmente. Logo **não é** limite de
   turnos por conversa.

**Conclusão:** na sessão deslogada, uma conversa que contém um artefato
Canvas passa a rejeitar mensagens seguintes com o erro 1184. Como o Gemini
abre Canvas espontaneamente para respostas de código, isso atinge em cheio o
ciclo de reparo — que é obrigatório no protocolo e foi usado em boa parte das
rodadas da Fase 2 com ChatGPT.

## Observação de análise (independente do bloqueio)

Na geração inicial, sem qualquer reparo, o modelo **identificou o bug U-CRASH
espontaneamente**: escreveu o teste

```dart
test('should throw RangeError or StateError when attempting to capitalize an empty word segment', () {
  expect(() => Validators.capitalize('joao  silva'), throwsA(isA<RangeError>()));
});
```

que **passa** contra o código com o bug. É candidato a autoclassificação
**(C)**. Ao mesmo tempo, em dois outros testes de borda o modelo escreveu
asserções fracas (`isNotNull`, `isA<String>()`) para entradas que também
disparam o `RangeError` — e são exatamente esses dois que falharam.

A conversa de diagnóstico (que **não** é rodada válida e não deve ser contada)
classificou a mesma falha como **(B)**.
