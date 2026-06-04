# INT-FS-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | INT-FS-01 |
| **Fluxo testado** | Login (LoginScreen → CadastroScreen / RecupSenhaScreen) |
| **Arquivos de origem** | `lib/login.dart`, `lib/cadastro.dart`, `lib/recup-senha.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-22 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | Flutter 3.41.6 / Dart 3.11.4 |

---

## Prompt Enviado

Template FS com exemplo do fluxo de playlist (INT-ZS-03 — 8/8) como referência de padrões corretos (pump sem pumpAndSettle, dois pumps para navegação, UI-only sem Firebase). Fluxo alvo: LoginScreen com validações de formulário e navegação para CadastroScreen e RecupSenhaScreen.

---

## Resposta do LLM

8 testes gerados corretamente seguindo o padrão do exemplo:
- `pump(Duration(seconds: 1))` em vez de `pumpAndSettle`
- dois pumps para navegação
- UI/validação apenas, sem Firebase
- imports corretos (`recup-senha.dart` com hífen)

**Arquivo gerado:** `test/integration/login_flow_fs_test.dart`

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução)** | 7 |
| **Testes falharam (1ª execução)** | 1 |
| **Testes passaram (pós-repair)** | 8 |
| **Testes falharam (pós-repair)** | 0 |

### Saída do terminal

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

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo enviado:**
```
O teste falhou: tap() em "Não tem cadastro? Cadastre-se!" gerou Offset(400, 664)
fora de Size(800, 600). Fix: adicionar tester.ensureVisible() + pump() antes do tap.
Corrigir apenas esse teste, manter os outros 7 intocados.
```

**Resposta do LLM:**
Adicionou `await tester.ensureVisible(find.text('Não tem cadastro? Cadastre-se!'))` + `await tester.pump()` antes do tap. Mudança cirúrgica, restante intacto.

**Resultado:**
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

### Iteração 2

Não necessária.

---

### Iteração 3

Não necessária.
