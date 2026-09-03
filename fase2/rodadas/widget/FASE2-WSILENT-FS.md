# FASE2-WSILENT-FS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-FS |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen` (`login()` — mapeamento de erros) |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-WSILENT-FS.md` — prompt few-shot
com um exemplo de widget test de formulário de login usando
`MockFirebaseAuth(authExceptions: AuthExceptions(...))`, seguido do
código completo de `LoginScreen` (mesmo bug W-SILENT da rodada ZS:
mensagens de `user-not-found`/`wrong-password` trocadas).

**Nota metodológica:** o exemplo few-shot usa uma API
(`authExceptions`/`AuthExceptions`) que **não existe** na versão
0.14.2 do `firebase_auth_mocks` instalada no projeto — é uma API de
versões antigas do pacote (removida a partir da 0.10.0, segundo o
próprio modelo). Isso não foi um erro do experimentador: é a mesma
forma de exemplo few-shot usada no template padrão do experimento
(`PROMPT_TEMPLATES.md`), e acabou induzindo o modelo a reproduzir uma
API obsoleta.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta"):

```
Abaixo está um arquivo de teste seguindo o padrão do exemplo, usando flutter_test + firebase_auth_mocks. Ele cobre validação, erros do Firebase e login bem-sucedido com navegação.

Observação: como LoginScreen usa Image.asset('assets/logo-sintoniza.png'), o teste pressupõe que esse asset esteja declarado no pubspec.yaml do projeto sintonize.
```

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// Ajuste estes imports conforme a estrutura do projeto.
import 'package:sintonize/login_screen.dart';
import 'package:sintonize/tela_inicial_screen.dart';

void main() {
  group('LoginScreen Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    // 4 testes de validação (e-mail vazio, e-mail inválido, senha
    //   vazia, senha curta)
    // 4 testes de erro do Firebase, um por código — usando a API
    //   inexistente MockFirebaseAuth(authExceptions: AuthExceptions(
    //   signInWithEmailAndPassword: FirebaseAuthException(code: '...')))
    // 1 teste de entrada de dados ('deve permitir informar e-mail e
    //   senha corretamente')
    // 1 teste de navegação após login bem-sucedido
    //
    // Ver test/fase2/widget/wsilent_fs_test.dart para o texto final
    // (pós-reparo) e a seção "Iterative Repair Loop" abaixo para o
    // texto original completo de cada teste corrigido.
  });
}
```

```
Pontos importantes

Há uma particularidade no código fornecido: as mensagens de user-not-found e wrong-password parecem estar trocadas:

if (e.code == 'user-not-found') {
  errorMessage = 'Senha incorreta...';
} else if (e.code == 'wrong-password') {
  errorMessage = 'Usuário não encontrado...';
}

Os testes acima reproduzem exatamente o comportamento atual do widget, em vez de assumir o comportamento esperado.

Também vale observar que o teste de navegação depende de TelaInicialScreen existir e estar importável. Se ela estiver no mesmo arquivo ou em outro caminho, basta ajustar o import.

Se quiser, também posso gerar uma versão mais robusta usando Mockito com verify() para verificar explicitamente que signInWithEmailAndPassword() foi chamado com o e-mail e a senha corretos.
```

**★ Detecção espontânea do bug-alvo (2ª vez seguida):** assim como em
FASE2-WSILENT-ZS, o modelo identificou e nomeou a inversão das
mensagens de erro já na primeira resposta, sem prompt de reparo, e
escreveu os testes fiéis ao comportamento real da aplicação.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `MockFirebaseAuth(authExceptions: AuthExceptions(...))` não existe na versão 0.14.2 instalada de `firebase_auth_mocks` |
| **Testes gerados** | 10 |
| **Testes passaram (após iteração 1 — API de mock trocada por `mock_exceptions`)** | 8 |
| **Testes falharam (após iteração 1)** | 2 |
| **Testes passaram (após iteração 2 — teste de senha corrigido)** | 8 |
| **Testes falharam (após iteração 2)** | 2 (nova falha de compilação: mesmo erro de `obscureText` da rodada FASE2-WSILENT-ZS) |
| **Testes passaram (após iteração 3 — final, máximo permitido)** | 9 |
| **Testes falharam (após iteração 3 — final)** | 1 |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/widget/wsilent_fs_test.dart:97:27: Error: Method not found: 'AuthExceptions'.
            authExceptions: AuthExceptions(
                            ^^^^^^^^^^^^^^
test/fase2/widget/wsilent_fs_test.dart:97:11: Error: No named parameter with the name 'authExceptions'.
../../AppData/Local/Pub/Cache/hosted/pub.dev/firebase_auth_mocks-0.14.2/lib/src/firebase_auth_mocks_base.dart:39:3: Context: Found this candidate, but the arguments don't match.
  MockFirebaseAuth(
  ^^^^^^^^^^^^^^^^
Compilation failed for testPath=test/fase2/widget/wsilent_fs_test.dart
```

(erro repetido nos 4 testes de código de erro do Firebase; saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_iter0.txt`)

### Saída do terminal (iteração 1 — 8/10)

2 falhas:
1. `deve permitir informar e-mail e senha corretamente` — `find.text('senha123'), findsNothing` falhou: `obscureText: true` afeta apenas a renderização, não impede `find.text` de localizar o valor no `EditableText`.
2. `deve navegar para TelaInicialScreen após login bem-sucedido` — `FirebaseException: [core/no-app]`, mesma limitação de testabilidade documentada em `FASE2-WSILENT-ZS` (`TelaInicialScreen` não recebe Firebase por injeção).

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_iter1.txt`)

### Saída do terminal (iteração 2 — nova falha de compilação)

```
test/fase2/widget/wsilent_fs_test.dart:289:22: Error: The getter 'obscureText' isn't defined for the type 'TextFormField'.
          senhaField.obscureText,
                     ^^^^^^^^^^^
Compilation failed for testPath=test/fase2/widget/wsilent_fs_test.dart
```

Ao corrigir a falha do item 1 acima, o modelo tentou `tester.widget<TextFormField>(...).obscureText` — **o mesmo erro exato já cometido e corrigido na rodada FASE2-WSILENT-ZS** (`obscureText` pertence a `TextField`/`EditableText`, não a `TextFormField`).

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_iter2.txt`)

### Saída do terminal (iteração 3 — final, 9/10, máximo de reparos atingido)

```
00:02 +9 -1: LoginScreen Widget deve navegar para TelaInicialScreen após login bem-sucedido [E]
FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:02 +9 -1: Some tests failed.
```

Apenas o teste de navegação após login bem-sucedido permanece falho —
a mesma limitação de testabilidade de `TelaInicialScreen` documentada
em `FASE2-WSILENT-ZS`, não corrigível sem alterar `lib/tela-inicial.dart`
(fora do escopo desta rodada).

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_iter3_final.txt`)

---

## ⚠️ Achado metodológico importante

Esta rodada reforça dois padrões já observados:

1. **Detecção espontânea consistente do bug W-SILENT** — 2ª vez seguida
   (ZS e FS) em que o modelo identifica e nomeia a inversão das
   mensagens de erro já na primeira resposta, sem repair, escrevendo os
   testes fiéis ao comportamento real da aplicação.

2. **A limitação de testabilidade de `TelaInicialScreen` é sistemática,
   não um acaso da rodada ZS** — em ambas as rodadas WSILENT até agora,
   o teste de "login bem-sucedido" falha pelo mesmo motivo
   (`TelaInicialScreen` acessa `FirebaseAuth.instance`/Firestore
   diretamente, sem injeção). Desta vez, ao ser informado sobre o
   achado da rodada anterior no próprio prompt de reparo, o modelo
   classificou corretamente como (B) **na primeira tentativa** (ao
   contrário da rodada ZS, que precisou de uma tentativa de correção
   fracassada antes de reconhecer a limitação) — sugerindo que o
   contexto adicional fornecido no prompt de reparo (mencionar o
   achado da rodada anterior) ajudou o modelo a evitar repetir o mesmo
   erro de diagnóstico.

3. **Um erro de API idêntico se repetiu entre rodadas independentes**
   — o mesmo engano (`TextFormField.obscureText` não existe; a
   propriedade pertence a `EditableText`) apareceu tanto em
   FASE2-WSILENT-ZS quanto, de forma independente (conversas novas,
   sem contexto compartilhado), nesta rodada FS — depois de o próprio
   modelo tentar corrigir uma primeira falha relacionada a
   `obscureText`. Isso sugere uma lacuna de conhecimento consistente do
   modelo sobre a API interna do Flutter (`TextFormField` vs.
   `TextField`/`EditableText`), não um erro aleatório.

4. **A API inexistente do prompt few-shot** (`AuthExceptions`) foi
   incorporada diretamente pelo modelo sem verificação — um risco
   inerente à estratégia few-shot quando o exemplo fornecido usa uma
   API desatualizada ou de outra versão do pacote.

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** compilação — `MockFirebaseAuth(authExceptions: AuthExceptions(...))` não existe na versão 0.14.2 de `firebase_auth_mocks` (API de versões antigas, removida a partir da 0.10.0).
- **Prompt de reparo enviado:** erro de compilação colado, com a assinatura real do construtor `MockFirebaseAuth` da versão instalada, sugerindo `mock_exceptions`/`whenCalling` como alternativa.
- **Resposta do LLM (completa e verbatim):**

```
A classificação é (A).

A falha é causada pelo teste presumir uma API de uma versão antiga do firebase_auth_mocks. A partir da versão 0.10.0, o pacote removeu o padrão AuthExceptions e passou a usar whenCalling(...).on(...).thenThrow(...); isso continua disponível na série 0.14.x.

Portanto, não é necessário alterar nem enfraquecer as asserções dos testes. Basta configurar as exceções de forma compatível com firebase_auth_mocks 0.14.2.

Teste corrigido

Adicione o import:

import 'package:mock_exceptions/mock_exceptions.dart';

[... os 4 testes de erro reescritos substituindo
MockFirebaseAuth(authExceptions: AuthExceptions(signInWithEmailAndPassword: FirebaseAuthException(code: '...')))
por
final authComErro = MockFirebaseAuth();
whenCalling(Invocation.method(#signInWithEmailAndPassword, null)).on(authComErro).thenThrow(FirebaseAuthException(code: '...'));
...]

Um detalhe importante sobre o comportamento da aplicação

Existe uma segunda questão, independente da falha de compilação. No LoginScreen fornecido, as mensagens estão invertidas: user-not-found → "Senha incorreta...", wrong-password → "Usuário não encontrado...". Isso parece potencialmente incorreto do ponto de vista funcional. Porém, não alterei os testes para esconder esse comportamento: eles continuam verificando exatamente o comportamento implementado atualmente.
```

- **Resultado:** compilou; 8/10 passaram, 2 falharam (detalhados acima).

### Iteração 2

- **Motivo da falha:** 2 falhas — asserção equivocada sobre `obscureText`/`find.text`, e a `FirebaseException` de `TelaInicialScreen`.
- **Prompt de reparo enviado:** as 2 falhas coladas, incluindo uma nota explícita de que uma rodada anterior deste experimento já havia mostrado que `Firebase.initializeApp()` com opções falsas não resolve o problema de `TelaInicialScreen` (para evitar repetir essa tentativa fracassada).
- **Resposta do LLM (resumo — completa em `fase2/resultados/widget/FASE2-WSILENT-FS_iter2.txt` e no histórico da conversa):** classificou a falha 1 como (A) — "o teste presumiu incorretamente que `obscureText: true` faria o Finder deixar de encontrar o valor" — e a falha 2 como (B), reconhecendo a limitação de testabilidade **imediatamente**, sem tentar `Firebase.initializeApp()` novamente, e recusando-se a alterar o teste de navegação. Para a falha 1, propôs verificar `tester.widget<TextFormField>(campos.at(1)).obscureText`.
- **Resultado:** nova falha de **compilação** — `obscureText` não é getter de `TextFormField` (o mesmo erro já corrigido na rodada FASE2-WSILENT-ZS, cometido de novo aqui de forma independente).

### Iteração 3 (final — máximo permitido)

- **Motivo da falha:** repetição do erro de API `TextFormField.obscureText`.
- **Prompt de reparo enviado:** o erro de compilação colado, apontando explicitamente que era o mesmo engano de antes, com a correção esperada (usar `find.descendant(..., matching: find.byType(EditableText))`) sugerida no próprio prompt.
- **Resposta do LLM (completa e verbatim):**

```
A classificação é (A).

O teste novamente presumiu uma API pública que TextFormField não possui. obscureText pertence ao TextField/EditableText, não ao TextFormField. A correção é inspecionar o EditableText descendente, como você indicou.

[... teste corrigido usando find.descendant(of: campos.at(1), matching: find.byType(EditableText)) e tester.widget<EditableText>(senhaField).obscureText ...]

Assim, a asserção verifica diretamente a propriedade no widget que realmente a expõe, sem depender da representação visual da senha nem de uma propriedade inexistente em TextFormField.

A classificação do segundo problema permanece (B): a dependência direta de Firebase em TelaInicialScreen é uma limitação de testabilidade da aplicação, e não deve ser mascarada alterando a asserção de navegação.
```

- **Resultado:** 9/10 passaram. Apenas o teste de navegação após login bem-sucedido permanece falho (limitação de testabilidade de `TelaInicialScreen`, documentada e não corrigível dentro do escopo). **Repair loop encerrado no limite de 3 iterações, sem 100% dos testes passando — resultado final: 9/10.**

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 (API obsoleta, correto); (A) e (B) corretas na iteração 2 (ao contrário da rodada ZS, acertou a classificação (B) da limitação de testabilidade já nesta tentativa, sem propor `Firebase.initializeApp()`); (A) na iteração 3 (mesmo erro de API repetido, autocorrigido corretamente ao ser apontado) |
| **★ Classificação humana (auditoria)** | Erro de geração (iteração 1 — API inexistente, induzida pelo exemplo few-shot desatualizado) / Erro de teste (iterações 2 e 3 — asserções equivocadas sobre `obscureText`/`find.text`) / Limitação de testabilidade (teste de navegação, `TelaInicialScreen` não injetável) |
| **★ Concordância** | Concorda integralmente — todas as classificações do modelo nesta rodada bateram com a auditoria humana, incluindo o reconhecimento correto e imediato da limitação de testabilidade de `TelaInicialScreen` (melhor que na rodada ZS) |
| **★ Observações** | Rodada com dois achados de reprodutibilidade valiosos para a tese: (1) confirma que a limitação de `TelaInicialScreen` é sistemática, não um acaso isolado, e que fornecer contexto de uma rodada anterior no prompt de reparo ajudou o modelo a diagnosticar corretamente de primeira; (2) o mesmo erro de API (`TextFormField.obscureText`) foi cometido de forma independente em duas rodadas/conversas diferentes, sugerindo uma lacuna de conhecimento consistente do modelo, não um erro aleatório. Esgotou as 3 iterações permitidas sem 100% — resultado final 9/10, documentado como está por protocolo. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
