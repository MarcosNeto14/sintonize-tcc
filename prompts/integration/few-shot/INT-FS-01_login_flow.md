# INT-FS-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | INT-FS-01 |
| **Fluxo testado** | Login (LoginScreen → CadastroScreen / RecupSenhaScreen) |
| **Arquivos de origem** | `lib/login.dart`, `lib/cadastro.dart`, `lib/recup-senha.dart` |
| **Nível da pirâmide** | Integration |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | _preencher_ |
| **Data de acesso** | 2026-05-22 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | Flutter 3.41.6 / Dart 3.11.4 |

---

## Prompt Enviado

Template FS com exemplo do fluxo de playlist (INT-ZS-03 — 8/8) como referência de padrões corretos (pump sem pumpAndSettle, dois pumps para navegação, UI-only sem Firebase). Fluxo alvo: LoginScreen com validações de formulário e navegação para CadastroScreen e RecupSenhaScreen.

---

## Resposta do LLM (Iteração 1)

8 testes gerados corretamente seguindo o padrão do exemplo:
- `pump(Duration(seconds: 1))` em vez de `pumpAndSettle`
- dois pumps para navegação
- UI/validação apenas, sem Firebase
- imports corretos (`recup-senha.dart` com hífen)

**Arquivo gerado:** `test/integration/login_flow_fs_test.dart`

---

## Resultado — Iteração 1

**Compilou?** Sim
**Testes gerados:** 8
**Passaram:** 7
**Falharam:** 1

```
+1: deve renderizar campos, botões e links                                PASS
+2: deve mostrar validação ao tentar login sem email                      PASS
+3: deve mostrar validação para email inválido                            PASS
+4: deve mostrar validação para senha curta                               PASS
+5: deve permitir digitar email e senha                                   PASS
-1: link "Não tem cadastro?" deve navegar para CadastroScreen             FAIL
    Widget off-screen: Offset(400, 664) > Size(800, 600)
    (botão "Não tem cadastro? Cadastre-se!" está abaixo do fold)
+6: link "Esqueci minha senha" deve navegar para RecupSenhaScreen         PASS
+7: não deve autenticar quando formulário for inválido                    PASS

00:03 +7 -1: Some tests failed.
```

**Diagnóstico:** o link "Não tem cadastro? Cadastre-se!" é o último item do Card dentro do `SingleChildScrollView`. No ambiente de teste (800×600px), ele renderiza em y=664 — fora dos limites. A navegação foi tentada mas falhou (tap não atingiu o widget). Fix: usar `tester.ensureVisible()` antes do tap.

---

## Iterações de Reparo

### Iteração 2

**Prompt de reparo enviado:**
```
O teste falhou: tap() em "Não tem cadastro? Cadastre-se!" gerou Offset(400, 664)
fora de Size(800, 600). Fix: adicionar tester.ensureVisible() + pump() antes do tap.
Corrigir apenas esse teste, manter os outros 7 intocados.
```

**Resposta do LLM:**
Adicionou `await tester.ensureVisible(find.text('Não tem cadastro? Cadastre-se!'))` + `await tester.pump()` antes do tap. Mudança cirúrgica, restante intacto.

**Resultado após correção:**
```
+1: deve renderizar campos, botões e links                                PASS
+2: deve mostrar validação ao tentar login sem email                      PASS
+3: deve mostrar validação para email inválido                            PASS
+4: deve mostrar validação para senha curta                               PASS
+5: deve permitir digitar email e senha                                   PASS
+6: link "Não tem cadastro?" deve navegar para CadastroScreen             PASS
+7: link "Esqueci minha senha" deve navegar para RecupSenhaScreen         PASS
+8: não deve autenticar quando formulário for inválido                    PASS
00:03 +8: All tests passed!
```

---

## Métricas Finais

| Métrica | Valor |
|---|---|
| **Testes gerados** | 8 |
| **Testes passando (final)** | 8/8 |
| **Iterações de reparo** | 2 |
| **Compilou na 1ª iteração?** | Sim |
| **Cobriu fluxo de sucesso?** | Não (login com Firebase impossível sem DI) |
| **Cobriu cenários de erro?** | Sim (3 validações de formulário) |
| **Cobriu navegação entre telas?** | Sim (CadastroScreen + RecupSenhaScreen) |

---

## Observações Qualitativas

- **Melhor resultado FS da fase Integration:** 8/8 em 2 iterações — a estratégia FS com exemplo correto (INT-ZS-03) produziu resultado imediato.
- **O exemplo few-shot foi decisivo:** LLM aplicou corretamente `pump(seconds:1)`, dois pumps para navegação e ausência de Firebase desde a iteração 1. Contrasta com ZS que precisou de 3 iterações para chegar ao mesmo padrão.
- **Única falha foi off-screen:** o link "Não tem cadastro?" estava abaixo do fold (y=664 > 600). Fix com `ensureVisible()` foi preciso e cirúrgico na iteração 2.
- **FS demonstrou transferência efetiva do padrão:** o exemplo mostrou `pump()+pump(500ms)` para navegação; o LLM aplicou em todos os 3 links de navegação sem errar nenhum pump.
