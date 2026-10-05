# FASE3-E2E-ZS-01_loginFlow — Gemini, tentativa 1 (2026-10-05) — ABORTADA, não conta

**Motivo:** a geração rodou com o seletor do Gemini em **Flash-Lite**, não em
**3.8 Flash**, a condição fixada para o Gemini em todas as fases (réplica da
Fase 2 e `template_rodada.md`). Modelo errado invalida a rodada; ela é refeita
por inteiro em conversa nova, com o seletor em 3.8 Flash.

- Conversa: `https://gemini.google.com/app/d44a89e2d1eaf5ae` (abandonada; nenhum reparo enviado).
- Print da tela no fim da geração, com o seletor visível ("Flash-Lite") e a
  resposta em Canvas ("E2E Login Test"):
  `evidencias/gemini/2026-10-05_ZS-01_tentativa1_seletor-flash-lite_canvas.png`.
- Prompt: `prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md`, sha256
  conferido, 33.976 caracteres, colado à mão pelo autor.
- Resposta literal (devolvida pelo autor, com a indentação irregular das
  primeiras linhas como veio): `FASE3-E2E-ZS-01_loginFlow_TENTATIVA-1_flash-lite/iter0_resposta.md`.
- Teste gerado, sem edição: `integration_test/fase3/gemini/_abortadas/login_zs_test.dart`
  (2 `testWidgets`). **Nunca executado.**
- Observado para o registro: resposta em inglês, código em Canvas, arquivo
  nomeado pelo modelo `login_flow_test.dart`.

**Por que não foi percebido antes do envio:** o print do seletor antes da
geração, que a réplica tornou evidência primária do modelo, não foi tirado. O
primeiro print da sessão (pós-geração) é o que mostra o Flash-Lite.
