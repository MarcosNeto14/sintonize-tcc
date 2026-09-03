# FASE2-WSILENT-ZS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-ZS |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen` (`login()` — mapeamento de erros) |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-WSILENT-ZS.md` — prompt zero-shot
pedindo widget tests para `LoginScreen`, com o código completo do widget
(contendo o bug W-SILENT: as mensagens de erro para os códigos
`user-not-found` e `wrong-password` estão trocadas — `user-not-found`
exibe "Senha incorreta...", que semanticamente deveria corresponder a
`wrong-password`, e vice-versa).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta" do ChatGPT;
"Pensou por 8s" indica uso de raciocínio estendido pelo próprio ChatGPT,
não solicitado pelo prompt zero-shot):

```
Abaixo está um arquivo de testes completo, por exemplo test/login_test.dart. Ele usa MockFirebaseAuth para o Firebase Auth e mock_exceptions para simular os diferentes FirebaseAuthException. A API atual de firebase_auth_mocks suporta explicitamente esse padrão de configuração de exceções.
```

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/login.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget createWidget() {
      return MaterialApp(home: LoginScreen(auth: mockAuth));
    }

    Future<void> preencherLogin(
      WidgetTester tester, {
      String email = 'usuario@email.com',
      String senha = '123456',
    }) async {
      await tester.enterText(find.byType(TextFormField).at(0), email);
      await tester.enterText(find.byType(TextFormField).at(1), senha);
    }

    // grupo 'renderização': 1 teste (elementos principais visíveis)
    // grupo 'validação do formulário': 4 testes (campos vazios, e-mail
    //   inválido, senha curta, e "não deve chamar Firebase Auth quando
    //   formulário for inválido")
    // grupo 'entrada de dados': 1 teste (inserir e-mail/senha)
    // grupo 'Firebase Auth': 6 testes — login bem-sucedido, e um teste
    //   por código de erro (user-not-found, wrong-password,
    //   invalid-credential, erro desconhecido/genérico)
    // grupo 'navegação': 2 testes (Esqueci minha senha, Cadastre-se)
    // grupo 'interação com botão Entrar': 1 teste (credenciais válidas)
    //
    // Ver test/fase2/widget/wsilent_zs_test.dart para o texto final
    // (pós-reparo) e a seção "Iterative Repair Loop" abaixo para o
    // texto original de cada teste corrigido.
  });
}
```

```
Dependências

Como o teste usa whenCalling(...), adicione mock_exceptions diretamente em dev_dependencies se ele ainda não estiver declarado no pubspec.yaml. Embora firebase_auth_mocks utilize essa biblioteca, declarar a dependência diretamente deixa o teste mais robusto e explícito. A documentação atual do firebase_auth_mocks recomenda exatamente esse mecanismo para configurar exceções.

dev_dependencies:
  flutter_test:
    sdk: flutter
  firebase_auth_mocks: ^0.15.2
  mock_exceptions: ^2.4.0
  mockito: ^5.4.0
  fake_cloud_firestore: ^3.1.0

Um detalhe importante sobre user-not-found e wrong-password

Há uma inversão no código original: user-not-found mostra "Senha incorreta...", enquanto wrong-password mostra "Usuário não encontrado...". Os testes acima reproduzem exatamente o comportamento implementado no seu LoginScreen, em vez de assumir as mensagens semanticamente esperadas.

Também não é necessário usar fake_cloud_firestore nesses testes, pois o LoginScreen não acessa Firestore. O MockFirebaseAuth é suficiente para isolar o login.

Observação: o teste de login bem-sucedido constrói a TelaInicialScreen, e os testes de navegação constroem RecupSenhaScreen/CadastroScreen. Portanto, esses arquivos também precisam estar compiláveis e, se essas telas carregarem assets adicionais, esses assets precisam existir no projeto Flutter.
```

**★ Detecção espontânea do bug-alvo:** o modelo identificou e nomeou
explicitamente a inversão das mensagens de erro **na primeira resposta**,
sem que nenhum prompt de reparo tivesse sido necessário para isso — e,
corretamente, escreveu os testes refletindo o comportamento real
(buggy) da aplicação em vez do comportamento semanticamente esperado,
alertando sobre a inconsistência em vez de "corrigi-la" silenciosamente.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `TextFormField.obscureText` não existe (é propriedade de `TextField`/`EditableText`, não de `TextFormField`) |
| **Testes gerados** | 14 |
| **Testes passaram (após iteração 1 — compilação corrigida)** | 10 |
| **Testes falharam (após iteração 1)** | 4 |
| **Testes passaram (após iteração 2 — tentativa de inicializar Firebase Core)** | 0 |
| **Testes falharam (após iteração 2)** | 14 (setUpAll quebrou a suíte inteira) |
| **Testes passaram (após iteração 3 — final, máximo permitido)** | 11 |
| **Testes falharam (após iteração 3 — final)** | 3 |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/widget/wsilent_zs_test.dart:167:29: Error: The getter 'obscureText' isn't defined for the type 'TextFormField'.
          expect(senhaField.obscureText, isTrue);
                            ^^^^^^^^^^^
Compilation failed for testPath=test/fase2/widget/wsilent_zs_test.dart
```

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-ZS_iter0.txt`)

### Saída do terminal (iteração 1 — 10/14)

4 falhas, todas ligadas a `TelaInicialScreen`/navegação:
1. `deve navegar para TelaInicialScreen após login bem-sucedido` — `FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created`.
2. `deve navegar ao tocar em Esqueci minha senha` — asserção equivocada do próprio teste (esperava o texto do botão da tela anterior na tela nova).
3. `deve navegar ao tocar em Cadastre-se` — `tap()` acertou um `Offset` fora da área visível (botão abaixo da dobra em `SingleChildScrollView`).
4. `deve aceitar credenciais válidas e autenticar o usuário` — mesma `FirebaseException` do item 1.

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-ZS_iter1.txt`)

### Saída do terminal (iteração 2 — regressão total, 0/14)

```
00:00 +0: (setUpAll)
00:00 +0 -1: (setUpAll) [E]
  PlatformException(channel-error, Unable to establish connection on channel., null, null)
  package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart 210:7  FirebaseCoreHostApi.initializeCore
00:00 +0 -1: (tearDownAll)
00:00 +0 -1: Some tests failed.
```

A correção sugerida pelo modelo (`Firebase.initializeApp()` com
`FirebaseOptions` falsas dentro de um `setUpAll`) quebrou a suíte
inteira: em `flutter test` puro não há canal de plataforma nativo do
Firebase disponível, então a própria inicialização falha antes de
qualquer teste rodar.

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-ZS_iter2.txt`)

### Saída do terminal (iteração 3 — final, 11/14, máximo de reparos atingido)

```
00:01 +6 -1: LoginScreen Firebase Auth deve navegar para TelaInicialScreen após login bem-sucedido [E]
00:01 +9 -1: LoginScreen Firebase Auth deve exibir mensagem genérica para erro desconhecido
00:01 +10 -1: LoginScreen navegação deve navegar ao tocar em Esqueci minha senha
00:01 +11 -1: LoginScreen navegação deve navegar ao tocar em Cadastre-se
00:02 +11 -2: LoginScreen navegação deve navegar ao tocar em Cadastre-se [E]
00:02 +11 -2: LoginScreen interação com botão Entrar deve aceitar credenciais válidas e autenticar o usuário
00:02 +11 -3: LoginScreen interação com botão Entrar deve aceitar credenciais válidas e autenticar o usuário [E]
00:02 +11 -3: Some tests failed.
```

3 falhas finais:
1. `deve navegar para TelaInicialScreen após login bem-sucedido` — `FirebaseException [core/no-app]` (limitação de testabilidade, ver reparo).
2. `deve navegar ao tocar em Cadastre-se` — `StateError: Bad state: Too many elements` dentro de `scrollUntilVisible(..., scrollable: find.byType(Scrollable))`, porque mais de um `Scrollable` existe na árvore de widgets (a correção da iteração 2 introduziu um finder ambíguo).
3. `deve aceitar credenciais válidas e autenticar o usuário` — mesma `FirebaseException` do item 1, seguida de falha na asserção do e-mail (`Expected: 'teste@sintonize.com' Actual: <null>`) porque a árvore quebrou antes.

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-ZS_iter3_final.txt`)

---

## ⚠️ Achado metodológico importante

Ao contrário das três rodadas W-CRASH (nenhuma detectou o bug-alvo), esta
rodada teve **detecção espontânea imediata** do bug W-SILENT — o modelo
identificou a inversão das mensagens de erro já na primeira resposta,
sem necessidade de reparo, e escreveu os testes refletindo fielmente o
comportamento (buggy) real da aplicação, com uma nota explícita
alertando sobre a inversão. Esse é o padrão mais próximo do observado no
nível Unitário até agora no nível Widget.

Por outro lado, esta rodada expõe uma **segunda limitação de
testabilidade real da aplicação**, distinta do bug-alvo: `LoginScreen`
navega, em caso de sucesso, para `TelaInicialScreen` via
`Navigator.pushReplacement`, e essa tela **não recebe suas dependências
de Firebase por injeção** (ao contrário de `LoginScreen`, que aceita
`FirebaseAuth? auth`) — ela acessa `FirebaseAuth.instance`/Firestore
diretamente em seu `initState()`. Isso torna **impossível testar o
fluxo de sucesso do login de forma isolada** sem alterar
`lib/tela-inicial.dart` (fora do escopo desta rodada), e nenhum dos 2
testes que dependem desse fluxo (login bem-sucedido; credenciais
válidas) pôde ser corrigido dentro dos limites do protocolo. O modelo,
na iteração final, reconheceu isso explicitamente e **recusou-se a
enfraquecer as asserções** para contornar o problema — uma resposta
correta ao protocolo de reparo (classificação B), mesmo sem conseguir
produzir uma correção funcional dentro do limite de 3 iterações.

O 3º teste que falhou na versão final (`Cadastre-se`) é uma consequência
colateral introduzida pela própria tentativa de correção do modelo na
iteração 2 (`scrollUntilVisible` com um finder `Scrollable` ambíguo,
que casa com mais de um widget na árvore) — não relacionado ao bug W-SILENT
nem à limitação do Firebase.

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** compilação — `TextFormField` não expõe `obscureText` como getter público; essa propriedade pertence a `TextField`/`EditableText`.
- **Prompt de reparo enviado:** erro de compilação colado, conforme template.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A) — o teste presume um comportamento que não é o especificado pela API usada.

O problema está no teste: obscureText é uma propriedade de TextField, não de TextFormField. O TextFormField internamente cria um TextField, que por sua vez utiliza um EditableText.

Portanto, não há indicação de problema no LoginScreen. O código da aplicação realmente declara obscureText: true; precisamos apenas inspecionar o widget correto.

Correção

Substitua este trecho:

final senhaField = tester.widget<TextFormField>(campos.at(1));
expect(senhaField.obscureText, isTrue);

por:

final senhaField = find.descendant(
  of: campos.at(1),
  matching: find.byType(EditableText),
);
expect(senhaField, findsOneWidget);
final editableText = tester.widget<EditableText>(senhaField);
expect(editableText.obscureText, isTrue);

Por que essa correção é adequada?

A hierarquia relevante é aproximadamente:
TextFormField └── TextField └── EditableText

O obscureText: true definido pela aplicação em TextFormField(obscureText: true, ...) é propagado para o campo editável interno. Portanto, verificar EditableText.obscureText mantém exatamente a intenção original do teste: garantir que a senha seja ocultada.

Não é necessário remover essa asserção ou simplesmente testar que o campo é um TextFormField; a propriedade de ocultação é um comportamento relevante da tela de login e pode ser testada dessa maneira.
```

- **Resultado:** compilou; 10/14 passaram, 4 falharam (detalhados acima).

### Iteração 2

- **Motivo da falha:** 4 falhas de naturezas distintas — `FirebaseException` (2x, tela de destino não isolada), asserção equivocada (1x), e `tap()` fora da área visível (1x).
- **Prompt de reparo enviado:** as 4 falhas coladas juntas, pedindo classificação individual.
- **Resposta do LLM (resumo — completa em `fase2/resultados/widget/FASE2-WSILENT-ZS_iter2.txt` e no histórico da conversa):** classificou as 4 como (A). Para as duas `FirebaseException`, recomendou inicializar `Firebase.initializeApp()` com `FirebaseOptions` fictícias em `setUpAll`. Para "Esqueci minha senha", recomendou trocar a asserção para `find.byType(RecupSenhaScreen)`. Para "Cadastre-se", recomendou `scrollUntilVisible` antes do `tap()`.
- **Resultado:** as correções de navegação ("Esqueci minha senha") funcionaram, mas a tentativa de `Firebase.initializeApp()` **quebrou a suíte inteira** (0/14) — `PlatformException(channel-error, ...)`, porque não há canal de plataforma nativo do Firebase disponível em `flutter test` puro (a sugestão do modelo não previu essa limitação de ambiente).

### Iteração 3 (final — máximo permitido)

- **Motivo da falha:** regressão total causada pela própria correção da iteração 2.
- **Prompt de reparo enviado:** o novo erro (`PlatformException` no `setUpAll`) colado, pedindo reclassificação e observando que este é o limite de 3 iterações, e perguntando explicitamente se há correção viável sem alterar `lib/tela-inicial.dart`.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (B) — o teste capturou uma limitação de testabilidade da aplicação.

O LoginScreen está razoavelmente testável porque recebe FirebaseAuth por injeção. Já o fluxo de sucesso não é isolável com o código atual: TelaInicialScreen.initState() chama fetchLastRecommendedMusic(), que acessa diretamente FirebaseAuth.instance e/ou Firestore.

Em flutter test puro não existe o host nativo do Firebase. Portanto, Firebase.initializeApp(...) não resolve isso sozinho; ele tenta atravessar o platform channel e produz PlatformException(channel-error, Unable to establish connection on channel.).

Por que não devemos alterar as asserções

Não seria correto transformar o teste em algo como expect(mockAuth.currentUser, isNotNull) e simplesmente ignorar a falha da TelaInicialScreen. Isso esconderia justamente o problema que o teste revelou.

O comportamento esperado é: credenciais válidas; LoginScreen autentica usando o FirebaseAuth injetado; navega para TelaInicialScreen; a tela de destino consegue ser construída sem depender de serviços Firebase reais no teste. O item 4 não é satisfeito atualmente porque TelaInicialScreen possui dependências concretas e globais.

O que é necessário para corrigir de verdade

Seria necessário alterar lib/tela-inicial.dart para aplicar a mesma estratégia usada pelo LoginScreen, injetando FirebaseAuth e a dependência do Firestore (auth/firestore opcionais no construtor, com fallback para as instâncias globais), e usar widget.auth/widget.firestore em vez de FirebaseAuth.instance/FirebaseFirestore.instance. No teste, seriam fornecidos MockFirebaseAuth e FakeFirebaseFirestore.

Portanto, dentro do escopo desta rodada: não há uma correção viável apenas no arquivo de teste que preserve o escopo e a força das asserções do teste de sucesso. A tentativa de Firebase.initializeApp() com FirebaseOptions falsas revelou uma segunda camada do problema: mesmo que o Firebase Core tivesse um mock de platform channel disponível, TelaInicialScreen continuaria acoplando seu initState() às instâncias globais de Firebase.

Como você explicitamente restringiu esta rodada a não alterar lib/tela-inicial.dart, não vou enfraquecer nem remover os testes de login bem-sucedido para fazê-los passar. Os testes de validação, entrada de dados, erros do Firebase Auth e navegação para recuperação/cadastro podem continuar sendo corrigidos/testados independentemente; o fluxo que termina em TelaInicialScreen exige uma mudança de arquitetura nessa tela para ser corretamente isolado.
```

- **Resultado:** por decisão de auditoria humana, o bloco `setUpAll` com `Firebase.initializeApp()` (que o próprio modelo reconheceu não resolver o problema e que quebrava toda a suíte) foi removido do arquivo de teste — não como uma nova iteração de reparo, mas como reversão de uma tentativa já esgotada e explicitamente identificada como sem solução dentro do escopo. As demais correções da iteração 2 (navegação para `RecupSenhaScreen`/`CadastroScreen`) foram mantidas. **Resultado final: 11/14.** Os 2 testes dependentes de `TelaInicialScreen` permanecem falhos (limitação de testabilidade documentada, não corrigível sem alterar `lib/tela-inicial.dart`), e o teste de "Cadastre-se" falha por um efeito colateral não previsto da correção da iteração 2 (`scrollUntilVisible` com finder `Scrollable` ambíguo). **Repair loop encerrado no limite de 3 iterações, sem 100% dos testes passando.**

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 (uso incorreto de `obscureText`, correto); (A) na iteração 2 para as 4 falhas, incluindo as 2 relacionadas a `TelaInicialScreen` (incorreto — seriam melhor classificadas como B/limitação de testabilidade já nessa iteração); (B) na iteração 3, ao reconhecer a limitação real após a tentativa de correção falhar |
| **★ Classificação humana (auditoria)** | Erro de teste (iteração 1 — API incorreta) / Limitação de testabilidade (as 2 falhas ligadas a `TelaInicialScreen`, desde a iteração 1) / Erro de teste (as 2 falhas de navegação — asserção equivocada e `tap()` fora de área visível) |
| **★ Concordância** | Parcial — o modelo só reconheceu a limitação de testabilidade na 3ª iteração, depois de sua própria correção (inicializar Firebase Core) falhar de forma nova e inesperada. Na 2ª iteração, classificar essas 2 falhas como (A) e propor uma correção que quebrou a suíte inteira foi um diagnóstico prematuro/incorreto. |
| **★ Observações** | Rodada com o achado mais rico até agora: (1) detecção espontânea do bug-alvo W-SILENT já na primeira resposta, sem repair; (2) descoberta de uma segunda limitação de testabilidade genuína (`TelaInicialScreen` não injetável), distinta do bug-alvo; (3) uma correção proposta pelo modelo (`Firebase.initializeApp()` em `setUpAll`) causou uma regressão total (0/14) que só foi diagnosticada corretamente uma iteração depois. Esgotou as 3 iterações permitidas sem 100% — resultado final 11/14, documentado como está por protocolo. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
