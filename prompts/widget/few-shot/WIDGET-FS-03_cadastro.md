# WIDGET-FS-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-FS-03 |
| **Widget testado** | CadastroScreen |
| **Arquivo de origem** | lib/cadastro.dart |
| **Complexidade** | Alta |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-15 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado

Template few-shot do `PROMPT_TEMPLATE_WIDGET.md` (exemplo de `MeuFormulario` + instrução "siga o mesmo padrão") seguido do código completo de `lib/cadastro.dart` (484 linhas — widget mais complexo: Firebase Auth + Firestore + HTTP ViaCEP + `_CEPInputFormatter` + `DropdownButtonFormField`) e lista de dependências de mock.

---

## Resposta do LLM

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';   // ← path CORRETO desta vez!

void main() {
  group('CadastroScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> pumpCadastro(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: CadastroScreen()));
      await tester.pumpAndSettle();
    }

    // 8 testWidgets usando find.widgetWithText(TextFormField, 'Nome'/'E-mail'/etc.)
    // (código completo em test/widget/cadastro_fs_test.dart)
  });
}
```

**Observação importante do LLM:** Reconheceu que `_submit()` não é mockado (FirebaseAuth.instance + FirebaseFirestore.instance hardcoded), e que `_fetchAddressFromCEP` precisaria de `http.Client` mockado. Sugeriu refatoração para DI — não aplicada.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 8 |
| **Testes passaram (pós-repair)** | 6 |
| **Testes falharam (pós-repair)** | 2 |
| **Setup correto de mocks?** | Parcial |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | Não |

### Saída do terminal

Saída completa salva em [`results/widget/few-shot/WIDGET-FS-03.txt`](../../../results/widget/few-shot/WIDGET-FS-03.txt).

Resumo das falhas:

- **Test 1** (`deve exibir erro ao tentar cadastrar com campos vazios`): `TestFailure: Found 0 widgets with text "O nome é obrigatório"`. Mesmo problema do ZS-03 1ª execução — `tap('Cadastrar')` não atinge o botão (botão em y≈870, viewport 800×600). Como o submit nunca é chamado, nenhuma mensagem de validação aparece.

- **Tests 2-8** (todos os outros): `StateError: Bad state: No element` em `enterText`. Causa: `find.widgetWithText(TextFormField, 'E-mail')` (e variações para Senha, CEP, Data, Número, Confirmar Senha, Nome) retorna 0 matches porque o label "E-mail" no widget é um `Text` **irmão** do `TextFormField` (dentro do helper `_buildTextField` o widget gera `Column([Text(label), SizedBox, TextFormField])`), **não** um filho/decoração do campo. Quando `enterText` chama `controller.state()` que usa `single` em iterable vazio → exceção.

**Achados experimentais:**

1. **FS quebrou o padrão de path errado em FS-03** — após FS-01 (`login_screen.dart`) e FS-02 (`criar_playlist_screen.dart`), em FS-03 o LLM usou `package:sintonize/cadastro.dart` (correto). Hipótese: o widget já se chama `CadastroScreen` (com o sufixo `Screen` no próprio nome da classe), então o LLM não adicionou um segundo sufixo no nome do arquivo. Pode também ser flutuação estatística — uma única amostra não confirma teoria.

2. **Falha estrutural por finder incorreto** — diferente de ZS-03 (que usou `find.byType(TextFormField).at(N)` e funcionou), o FS preferiu `find.widgetWithText(TextFormField, 'Label')`. Isso falha porque o widget colocou os labels **fora** do `TextFormField` (em um `Text` irmão). O exemplo do prompt few-shot (`MeuFormulario`) é abstrato demais para informar sobre essa decisão arquitetural — então o LLM assumiu um padrão comum (`labelText` no `InputDecoration`) que não é o que o widget faz.

3. **Trade-off zero-shot vs few-shot ficou nítido na cobertura** — FS-03 cobriu validação de **data** (que ZS-03 não testou) e usou finder com label semântico (mais legível). Mas o finder semântico falhou por incompatibilidade estrutural; o finder posicional do ZS-03 (`.at(N)`) funcionou. **Robustez ≠ legibilidade.**

4. **Problema de scroll voltou** — FS não aprendeu com FS-01/FS-02 (porque cada rodada é conversa nova). Mesmo problema do ZS-03 1ª execução (botão Cadastrar fora do viewport), mesma falta de `ensureVisible()`. Sugere que **o repair loop do ZS-03 não generaliza para outras rodadas** — cada conversa começa do zero.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim — erros heterogêneos potencialmente diagnosticáveis pelo log (scroll + finder errado)
- **Motivo da falha:** Test 1 falha por scroll/hit-test do botão Cadastrar; tests 2-8 falham por `find.widgetWithText(TextFormField, 'Label')` retornando 0 matches (label é Text irmão, não filho).
- **Prompt de correção:** Erro completo (TestFailure no test 1 + 7 StateErrors + warning de hit-test) enviado ao LLM.
- **Resposta do LLM:** Diagnóstico preciso e correto de **3 problemas distintos**: (1) "teclado/foco falhando — usar pumpAndSettle + ensureVisible"; (2) "labels são Text irmãos, não labelText — evitar widgetWithText em formulários complexos"; (3) "botão fora da viewport — usar setSurfaceSize ou ensureVisible". Reescreveu todos os 8 testes: trocou `find.widgetWithText(TextFormField, 'Label')` por `find.byType(TextFormField).at(N)`, adicionou `tester.binding.setSurfaceSize(const Size(1200, 2000))` no helper `pumpCadastro`, `ensureVisible(cadastrarBtn)` no test 1, substituiu `pump()` por `pumpAndSettle()`. Removeu imports não usados de Firebase mocks.
- **Resultado:** **Passaram 6/8** (saltou de 0 para 6). Falhas residuais:
  - "deve validar data inválida": LLM enviou `'999999'` no campo data. O `TextInputFormatter` do widget transforma em `'99/99/99'` automaticamente. `_validateDate` então parseia day=99, month=99, year=99; falha em `month > 12` → retorna `'Mês deve ser entre 01 e 12'`. O teste esperava `'Formato inválido. Use dd/mm/aaaa'`, que só aparece quando o split por `/` não dá 3 partes (impossível com o formatter ativo). **Achado:** LLM não simulou mentalmente o efeito do formatter.
  - "deve validar número não numérico": LLM usou `find.byType(TextFormField).at(8)` para Número. Pelo layout (Nome[0], DataNasc[1], Email[2], Senha[3], ConfSenha[4], CEP[5], Rua[6], **Número[7]**, Bairro[8], Cidade[9]), `.at(8)` é o campo Bairro, que não tem validador. O 'ABC' digitado em Bairro foi aceito; o erro de "número não numérico" não apareceu (Número segue vazio, mas o erro retornado seria 'O número é obrigatório', não 'O número deve ser numérico'). **Achado:** LLM contou os campos com offset de 1 — mesmo problema que ZS-03 evitou usando `.at(7)` corretamente.

### Iteração 2
- **Necessária?** Não — loop encerrado na Iteração 1 por decisão metodológica. As 2 falhas residuais não são diagnosticáveis pelo log de erro (`Found 0 widgets`); a causa raiz exige raciocínio sobre o efeito do `TextInputFormatter` (data) e contagem correta de campos no formulário (número). Iter2 sem essa informação tenderia ao chute.

### Iteração 3
- **Necessária?** Não — loop encerrado na Iteração 1

---

## Achados consolidados — WIDGET-FS-03

1. Path correto em FS-03 (`sintonize/cadastro.dart`): classe já se chama `CadastroScreen` — LLM não adicionou segundo sufixo. ZS-03 também acertou; login e criarPlaylist divergiram. Necessita amostra maior.
2. Repair eficaz contra falhas estruturais: 1 iteração diagnosticou 3 problemas (viewport, finder semântico, foco) e saltou de 0 para 6 testes.
3. Repair falha contra erros de modelo mental: efeito do `TextInputFormatter` (data `'999999'` → `'99/99/99'` pelo formatter → erro de mês, não de formato) e índice off-by-one em `.at(8)` vs `.at(7)` para o campo Número.
4. Trade-off ZS vs FS em Cadastro: ZS gerou finder posicional direto (funcional); FS gerou finder semântico por label (mais legível, mas incompatível com a estrutura real do widget).
