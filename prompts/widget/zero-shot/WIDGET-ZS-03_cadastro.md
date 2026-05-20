# WIDGET-ZS-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-ZS-03 |
| **Widget testado** | CadastroScreen |
| **Arquivo de origem** | lib/cadastro.dart |
| **Complexidade** | Alta |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-15 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado

Mesmo template zero-shot do `PROMPT_TEMPLATE_WIDGET.md`, com o código completo de `lib/cadastro.dart` (484 linhas — o widget mais complexo do experimento, com Firebase Auth + Firestore + HTTP ViaCEP + `_CEPInputFormatter` custom + DropdownButtonFormField para estados) embutido no marcador `[COLAR O CÓDIGO COMPLETO DO WIDGET AQUI]`. Estrutura idêntica às rodadas anteriores: instrução + código + projeto + dependências de mock + 7 requisitos.

---

## Resposta do LLM

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/cadastro.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidget() {
    return const MaterialApp(
      home: CadastroScreen(),
    );
  }

  group('CadastroScreen Widget Tests', () {
    // 11 testWidgets gerados (renderização, validações vazias, validações de regra,
    // dropdown estado, navegação, inserção de texto)
    // (código completo dos testes em test/widget/cadastro_zs_test.dart)
  });
}
```

**Observações importantes do LLM:**

> Como o widget usa `FirebaseAuth.instance` diretamente, os testes acima focam principalmente em UI e validação.
> Para testar `_submit()` completamente, o ideal é refatorar a tela para receber `FirebaseAuth` e `FirebaseFirestore` por injeção de dependência.

O LLM também sugeriu criar um `test/flutter_test_config.dart` para `WidgetsFlutterBinding.ensureInitialized()`, mas a sugestão não foi aplicada (mantida fidelidade ao arquivo de teste isolado).

(Resposta integral com os 11 testWidgets preservada em `test/widget/cadastro_zs_test.dart`.)

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 11 |
| **Testes passaram (1ª execução)** | 4 |
| **Testes falharam (1ª execução)** | 7 |
| **Testes passaram (pós-repair)** | 10 |
| **Testes falharam (pós-repair)** | 1 |
| **Setup correto de mocks?** | Parcial |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | Não |

### Saída do terminal

Saída completa salva em [`results/widget/zero-shot/WIDGET-ZS-03.txt`](../../../results/widget/zero-shot/WIDGET-ZS-03.txt).

Resumo:

```
00:03 +4 -7: Some tests failed.
```

**Testes que passaram (4):**
1. `Deve renderizar os campos principais`
2. `Deve aceitar preenchimento válido dos campos` (passou por coincidência — ver achado abaixo)
3. `Deve navegar para login ao clicar no botão`
4. `Deve inserir texto nos campos`

**Testes que falharam (7):**
1. `Deve mostrar erros ao submeter formulário vazio` — `Found 0 widgets with text "O nome é obrigatório"`
2. `Deve validar e-mail inválido` — `Found 0 widgets with text "E-mail inválido"`
3. `Deve validar senha curta` — `Found 0 widgets with text "A senha deve ter pelo menos 6 caracteres"`
4. `Deve validar confirmação de senha` — `Found 0 widgets with text "As senhas não coincidem"`
5. `Deve validar CEP inválido` — `Found 0 widgets with text "CEP inválido. Formato correto: XXXXX-XXX"`
6. `Deve validar número inválido` — `Found 0 widgets with text "O número deve ser numérico"`
7. `Deve selecionar estado no dropdown` — `StateError: Bad state: No element` (find.text('PE').last em iterable vazio)

**Achado experimental — falha sistemática por scroll:**

Os 6 primeiros testes falharam pelo **mesmo motivo subjacente**: o botão "Cadastrar" está em `Offset(400, 870)`, mas o viewport de teste é `Size(800, 600)`. Logo o `tap()` não atinge o botão. Confirmado por warning repetido no terminal:

```
Warning: A call to tap() with finder "Found 1 widget with text "Cadastrar"..."
derived an Offset (Offset(400.0, 870.0)) that would not hit test on the specified widget.
Indeed, Offset(400.0, 870.0) is outside the bounds of the root of the render tree, Size(800.0, 600.0).
```

Como o submit nunca é acionado, o formulário nunca é validado, e portanto **nenhuma mensagem de erro aparece** — os 6 `expect(find.text('...'), findsOneWidget)` falham.

O LLM zero-shot **não previu o problema de scroll** em widgets longos dentro de `SingleChildScrollView`. Para o experimento, este é um achado independente da questão de mocks de Firebase: é uma falha de **modelo mental** do LLM sobre o ambiente de teste do flutter_test (viewport fixo 800×600 vs. tela real do dispositivo).

O dropdown também falhou por motivo similar (provavelmente fora do viewport ou item 'PE' não rendered porque o overlay do dropdown abre fora da área visível).

O teste "Deve aceitar preenchimento válido" passou por **coincidência** — ele preenche todos os campos, depois tapa "Cadastrar" (que não atinge), e verifica `findsNothing` para mensagens de erro. Como o submit nunca foi acionado, nenhuma mensagem aparece e o assert passa. Falso positivo.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** 6 testes falham porque o `tap('Cadastrar')` não atinge o botão (offset y=870 fora do viewport 800×600); 1 teste falha no dropdown ('PE'.last sobre iterable vazio).
- **Prompt de correção:** Erro completo da 1ª execução enviado ao LLM (warnings de hit-test + 6 mensagens "Found 0 widgets" + erro do dropdown "Bad state: No element").
- **Resposta do LLM:** Diagnosticou corretamente que o botão está fora da área visível e propôs (1) helper `tapCadastrar(tester)` usando `tester.ensureVisible()` + `pumpAndSettle()` antes do tap, (2) `ensureVisible()` também no botão "Já tem uma conta?", (3) `ensureVisible()` no dropdown antes de abrir, (4) troca de `.last` por `.first` no `find.text('PE')`. Reescreveu todos os 11 tests.
- **Resultado:** **Passou 10/11** (saltou de 4 para 10). Falha residual: "Deve selecionar estado no dropdown" — `Found 0 widgets with text 'PE'` após tap no dropdown. Apesar do `ensureVisible()`, o overlay de itens do `DropdownButtonFormField` ou não abriu ou os itens não foram encontrados pelo finder de texto.

### Iteração 2
- **Necessária?** Sim
- **Motivo da falha:** Apesar do `ensureVisible(dropdown)` + `pumpAndSettle()` aplicados na Iteração 1, `find.text('PE')` retornava `Found 0 widgets` após tap no `DropdownButtonFormField` — o overlay com os itens do dropdown não estava acessível ao finder de texto.
- **Prompt de correção:** Erro residual da Iteração 1 (apenas o teste do dropdown — `Found 0 widgets with text "PE"`).
- **Resposta do LLM:** Diagnosticou como problema do overlay do Dropdown. Substituiu apenas o teste do dropdown; trocou `find.text('PE')` por `find.byWidgetPredicate((w) => w is DropdownMenuItem<String> && w.value == 'PE')` para localizar o item pela tipagem do widget em vez do texto.
- **Resultado:** Falhou novamente (10/11 idêntico à Iteração 1). Novo erro: `Found 0 widgets with widget matching predicate` — mesmo o `DropdownMenuItem<String>` não foi encontrado. Causa provável: o dropdown está em y≈820 no viewport e abre **para baixo**; em viewport 800×600, o overlay com os itens não cabe abaixo do botão.

### Iteração 3
- **Necessária?** Não — loop encerrado na Iteração 2 por decisão metodológica (rendimento zero entre iter1 e iter2 indica que o LLM não tem mais informação para inferir; achado completo já documentado)

---

## Achados consolidados — WIDGET-ZS-03

- Viewport 800×600 causou falha sistemática em 6/11 testes na 1ª execução (botão "Cadastrar" em y≈870 fora do viewport) — falha de modelo mental do LLM sobre o ambiente de teste.
- Repair com warning explícito é eficaz: `ensureVisible()` corrigiu o scroll em 1 iteração, saltando de 4 para 10 testes passando.
- Overlay do `DropdownButtonFormField` em viewport apertado não é diagnosticável pelo log ("Found 0 widgets" não revela falta de espaço); LLM tentou `find.byWidgetPredicate` na iter2 sem resolver — repair tem rendimento decrescente quando a causa raiz não aparece no erro.
- Falso positivo em "Deve aceitar preenchimento válido": passou trivialmente na 1ª execução (submit nunca acionado) e continuou passando pós-repair (submit falhou silenciosamente com `FirebaseException`). Categoria de assert fraco relevante para análise qualitativa.
