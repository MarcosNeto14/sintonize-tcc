# WIDGET-ZS-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-ZS-03 |
| **Widget testado** | CadastroScreen |
| **Arquivo de origem** | lib/cadastro.dart |
| **Complexidade** | Alta |
| **Nível da pirâmide** | Integração (Widget Test) |
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
| **Testes passaram (pós-repair)** | 10 (após 2 iterações de reparo) |
| **Testes falharam (pós-repair)** | 1 (somente o teste do dropdown — `find.byWidgetPredicate` para `DropdownMenuItem<String>` retorna 0 mesmo após `ensureVisible + pumpAndSettle`) |
| **Setup correto de mocks?** | Parcial — criou `MockFirebaseAuth` e `FakeFirebaseFirestore`, mas não injetou (mesmo padrão de ZS-01 e ZS-02; widget acopla `FirebaseAuth.instance` e `FirebaseFirestore.instance` direto). Como nenhum teste tenta efetivamente submeter um formulário **válido** com tap real no botão (ver achado abaixo), a falta de DI não chegou a quebrar testes por `FirebaseException` — eles falham antes, por outro motivo. |
| **MaterialApp wrapper?** | Sim — `MaterialApp(home: CadastroScreen())`. |
| **Tratou assets?** | Não — não tratou o `Image.asset('assets/logo-sintoniza.png')`. Não causou falha porque nenhum teste verifica o conteúdo da imagem. |
| **Tipos de teste gerados** | Renderização (1), Submit form vazio (1), Validação de regra por campo (5 — email, senha, confirmação, CEP, número), Submit form preenchido (1), Navegação (1), DropdownButtonFormField (1), Entrada de texto (1) |
| **Nota metodológica** | Os campos "1ª execução" refletem a saída do `flutter test` antes de qualquer iteração de repair. Os campos "pós-repair" refletem o estado final após todas as iterações. |

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

1. **Zero-shot subestima o viewport de teste:** o LLM gerou taps no botão "Cadastrar" sem prever que ele estaria fora do viewport 800×600. Falha sistemática em 6 dos 11 testes na 1ª execução, todos pela mesma raiz.
2. **Repair loop resolve problemas observáveis no erro:** quando o erro vem com warning explícito ("would not hit test"), o LLM corrige com `ensureVisible()` em uma iteração. Resultado: salto de 4 para 10 testes.
3. **Limite estrutural não diagnosticável pelo erro:** o overlay do `DropdownButtonFormField` em viewport apertado é um problema cujo erro ("Found 0 widgets") **não revela** a causa raiz (espaço insuficiente para o overlay). O LLM trocou de estratégia (`find.text` → `find.byWidgetPredicate`) sem entender o problema real, e iter2 falhou igualmente. **Achado-chave:** o repair loop tem rendimento decrescente quando a causa raiz não está visível no log de erro.
4. **Falso positivo em "Deve aceitar preenchimento válido":** o teste passou na 1ª execução por motivo errado (o tap em "Cadastrar" não atingia o botão, então o submit nunca rodava, então não havia mensagens de erro — o `findsNothing` passava trivialmente). Após a correção da Iteração 1, o teste continuou passando porque agora o submit **roda** mas falha com `FirebaseException` antes de mostrar qualquer mensagem de erro visível — outro tipo de falso positivo (mesmo assert, motivo diferente). Vale considerar essa categoria de teste como **assert fraco** na análise qualitativa do TCC.
