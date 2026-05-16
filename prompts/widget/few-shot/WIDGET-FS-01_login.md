# WIDGET-FS-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-FS-01 |
| **Widget testado** | LoginScreen |
| **Arquivo de origem** | lib/login.dart |
| **Complexidade** | Baixa |
| **Nível da pirâmide** | Integração (Widget Test) |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-15 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado

Template few-shot do `PROMPT_TEMPLATE_WIDGET.md`. Estrutura:
1. Instrução "Gere widget tests em Dart usando flutter_test para o widget abaixo. Antes, veja um exemplo de widget test bem escrito para um formulário Flutter com Firebase mockado:"
2. Bloco ```dart``` com **exemplo de widget test** de um `MeuFormulario` fictício, mostrando `MockFirebaseAuth` em `setUp`, dois `testWidgets` (email vazio, email inválido) usando `find.byType(TextFormField).first` e `find.text(...)`.
3. "Agora, gere widget tests para este widget, seguindo o mesmo padrão do exemplo:"
4. Bloco ```dart``` com o código completo de `lib/login.dart` (219 linhas).
5. Parágrafo "O widget faz parte do projeto Flutter 'sintonize'." + lista de dependências de mock.

---

## Resposta do LLM

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login_screen.dart';   // ← path alucinado (correto: sintonize/login.dart)

void main() {
  group('LoginScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Future<void> pumpLoginScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );
    }

    // 7 testWidgets: email vazio, email inválido, senha vazia, senha curta,
    // renderização, digitação, sem erros com dados válidos
    // (código completo em test/widget/login_fs_test.dart)
  });
}
```

Sem observações metodológicas extras nesta rodada — o LLM apenas listou as dependências esperadas no pubspec.yaml e o comando `flutter test`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | **Não** |
| **Testes gerados** | 7 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 7 (todos por falha de compilação) |
| **Testes passaram (pós-repair)** | 0 (loop encerrado na Iteração 1 por decisão metodológica — padrão idêntico ao ZS-02) |
| **Testes falharam (pós-repair)** | 7 (continuam por falha de compilação; LLM em loop de adivinhação de nome de arquivo) |
| **Setup correto de mocks?** | Parcial — segue o padrão do exemplo (cria `MockFirebaseAuth` no `setUp`), mas não injeta (mesma limitação dos ZS porque o widget usa `FirebaseAuth.instance` direto). |
| **MaterialApp wrapper?** | Sim — `MaterialApp(home: LoginScreen())` via helper `pumpLoginScreen`. |
| **Tratou assets?** | N/A — falha de compilação não chegou a renderizar; não há tratamento explícito de assets no código. |
| **Tipos de teste gerados** | Validação de form (4 — email vazio, email inválido, senha vazia, senha curta), Renderização (1), Digitação (1), Caso de sucesso "sem erros" (1) |
| **Nota metodológica** | Os campos "1ª execução" refletem a saída do `flutter test` antes de qualquer iteração de repair. Os campos "pós-repair" refletem o estado final após todas as iterações. |

### Saída do terminal

Saída completa salva em [`results/widget/few-shot/WIDGET-FS-01.txt`](../../../results/widget/few-shot/WIDGET-FS-01.txt).

Erro:

```
test/widget/login_fs_test.dart:6:8: Error: Error when reading 'lib/login_screen.dart': O sistema não pode encontrar o arquivo especificado
import 'package:sintonize/login_screen.dart';
       ^
test/widget/login_fs_test.dart:19:17: Error: Method not found: 'LoginScreen'.
          home: LoginScreen(),
                ^^^^^^^^^^^
```

**Achado experimental — comparação ZS vs FS no mesmo widget:**

- WIDGET-ZS-01 importou `package:sintonize/login.dart` (path **correto**)
- WIDGET-FS-01 importou `package:sintonize/login_screen.dart` (path **errado**)

Mesmo widget, mesmo modelo, mesma temperatura aparente — o **few-shot piorou** a inferência de path. Hipótese: o exemplo no prompt mostra `MeuFormulario` como widget fictício, e o LLM pode ter inferido implicitamente uma convenção de nomenclatura `<Feature>Screen` em `<feature>_screen.dart` ao misturar o estilo do exemplo com o widget-alvo. Achado relevante para a discussão do TCC: **few-shot não é estritamente superior a zero-shot** — exemplos podem introduzir vieses de convenção que prejudicam a inferência sobre o projeto real.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** Path alucinado no import (`sintonize/login_screen.dart` em vez de `sintonize/login.dart`) — cascateia em erro de "Method not found: 'LoginScreen'".
- **Prompt de correção:** Erro de compilação completo enviado ao LLM (mesmos 2 erros: arquivo não encontrado + Method not found).
- **Resposta do LLM:** Trocou o package import por **import relativo** (`import '../../lib/login_screen.dart';`) mantendo o **mesmo nome de arquivo errado** (`login_screen.dart`). Adicionou uma observação dizendo que se o arquivo for `login_screen.dart`, o package import original estaria correto desde que o `pubspec.yaml` tenha `name: sintonize` — efetivamente devolvendo o problema ao usuário em vez de inferir o nome correto. Também **removeu o import de `firebase_auth_mocks`** (regressão na qualidade dos mocks).
- **Resultado:** Falhou — mesmo erro, agora com path relativo (`Error when reading 'lib/login_screen.dart': O sistema não pode encontrar o arquivo`). O LLM continua fixado no sufixo `_screen.dart` que **não existe** no projeto.

### Iteração 2
- **Necessária?** Não — loop encerrado na Iteração 1

### Iteração 3
- **Necessária?** Não — loop encerrado na Iteração 1

---

## Achados consolidados — WIDGET-FS-01

1. **Few-shot piorou a inferência de path em relação ao zero-shot:** ZS-01 acertou (`sintonize/login.dart`); FS-01 errou (`sintonize/login_screen.dart`). Hipótese: o exemplo no prompt mostra `MeuFormulario` como widget fictício, e o LLM pode ter inferido uma convenção `<Feature>Screen` em `<feature>_screen.dart` ao misturar o padrão do exemplo com o widget-alvo.
2. **LLM regrediu na qualidade do mock durante o repair:** removeu o import de `firebase_auth_mocks` e o `MockFirebaseAuth` do `setUp` ao reescrever o teste na Iteração 1, mesmo o erro sendo apenas de path. Indica que o repair loop pode degradar partes do código que **não estavam quebradas**.
3. **Padrão de loop de adivinhação confirmado:** mesmo comportamento do ZS-02 — sem informação sobre a estrutura real do projeto, o LLM alterna entre convenções estatisticamente plausíveis (package import com nome alucinado → import relativo com mesmo nome alucinado). O prompt de reparo "só o erro" não tem como interromper isso.
