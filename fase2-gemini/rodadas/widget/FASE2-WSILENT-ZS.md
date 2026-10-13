# FASE2-WSILENT-ZS — Réplica Gemini

Rodada **10/60**. Abre o bloco W-SILENT.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-ZS |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen.login()` |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`. W-SILENT confirmado: `lib/login.dart:41-42` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/wsilent_zs_test.dart` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WSILENT-ZS_iter{0,1,2_final}.txt` |
| **Modo de execução** | Manual (operador colou prompt e respostas) |

---

## O bug plantado

Em `login.dart`, as mensagens de dois códigos de erro estão **trocadas**:

```dart
if (e.code == 'user-not-found') {
  errorMessage = 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
} else if (e.code == 'wrong-password') {
  errorMessage = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
}
```

Usuário inexistente recebe "senha incorreta"; senha errada recebe "usuário não
encontrado". Nada quebra — é silencioso por construção.

**O prompt aponta direto para esse trecho.** Entre os requisitos está, literalmente:

> "Teste as mensagens de erro retornadas para diferentes códigos de exceção do
> Firebase Auth"

É a condição mais favorável possível à detecção em todo o bloco widget: o
requisito nomeia exatamente a região onde o defeito mora.

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-WSILENT-ZS.md`, do separador
`---` em diante: código completo de `LoginScreen`, dependências de mock e 8
requisitos, incluindo o citado acima. Traz a linha de ajuda do caminho de
import.

---

## Resposta do LLM — geração inicial

11 testes em 5 grupos: renderização, validação de formulário, fluxo de
sucesso, tratamento de erros do Firebase Auth e navegação secundária.

Cumpriu o requisito das mensagens de erro com **um teste por código**:
`user-not-found`, `wrong-password`, `invalid-credential` e um genérico
(`network-request-failed`).

E em cada um **copiou a string do código como valor esperado**:

```dart
// teste de 'user-not-found'
expect(
  find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
  findsOneWidget,
);

// teste de 'wrong-password'
expect(
  find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
  findsOneWidget,
);
```

**Nenhuma menção à inversão**, nem no código, nem na prosa, nem na seção
"Principais Pontos dos Testes" ao final da resposta.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 11 |
| **Testes passaram (1ª execução)** | 4 |
| **Testes falharam (1ª execução)** | 6 |
| **Iterações de reparo** | 2 |
| **Testes passaram (pós-repair)** | **10** |
| **Testes falharam (pós-repair)** | **1** |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não — o oposto: o bug foi fixado como comportamento esperado** |
| **Bug plantado mencionado na resposta?** | **Não** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** 6 falhas, todas de infraestrutura de mock, nenhuma
  relacionada ao bug plantado:
  - `[core/no-app] No Firebase App '[DEFAULT]'` no fluxo de sucesso —
    `pushReplacement` monta `TelaInicialScreen`, cujo `initState` chama
    `FirebaseAuth.instance` estático.
  - `type 'Null' is not a subtype of type 'Future<UserCredential>'` —
    `class MockFirebaseAuthWithExceptions extends Mock implements FirebaseAuth`
    sem mocks gerados não satisfaz null-safety.
  - `Bad state: Cannot call 'when' within a stub response` — consequência do
    anterior, nos outros três testes de erro.
  - `CadastroScreen` não encontrada — botão fora do viewport de 800x600 dentro
    do `SingleChildScrollView`.
- **★ Autoclassificação do modelo:** **(A)**, com diagnóstico correto dos três
  problemas.
- **Correção proposta:** trocou o mock manual do mockito por
  `class FakeFirebaseAuthWithException extends MockFirebaseAuth`, sobrescrevendo
  só `signInWithEmailAndPassword` para lançar a exceção; substituiu a asserção
  de navegação por um `NavigatorObserver` próprio; adicionou
  `tester.ensureVisible()` antes dos taps de navegação.
- **Resultado:** **10 passaram, 1 falhou.**
- Saída: `FASE2-WSILENT-ZS_iter1.txt`

### Iteração 2

- **Motivo da falha:** a falha remanescente, `[core/no-app]` no fluxo de
  sucesso. O `pump()` único não impede a montagem de `TelaInicialScreen`.
- **★ Autoclassificação do modelo:** **(B)** — bug real exposto.
- **Resposta:** coerente com o caminho (B), **não devolveu código**.
  Diagnosticou:

  > "No código de `LoginScreen`, a dependência de autenticação foi corretamente
  > externalizada via injeção de dependência (...). No entanto, a aplicação
  > quebra esse padrão de design imediatamente na linha seguinte: (...)
  > `MaterialPageRoute(builder: (context) => const TelaInicialScreen())`"

  E concluiu que a correção pertence a `TelaInicialScreen`, não ao teste.
- **Resultado:** sem correção. A rodada encerra em 10/11; a iteração 3 não foi
  usada.
- Saída final: `FASE2-WSILENT-ZS_iter2_final.txt` (idêntica à da iteração 1,
  já que nenhum código novo foi produzido).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)** na iteração 1, **(B)** na iteração 2. Ambas declaradas explicitamente. |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de teste** — correto. Iteração 2: **Limitação de testabilidade** — o modelo chamou de (B)/bug real; é de fato um defeito de desenho da aplicação, não um bug de comportamento. |
| **★ Concordância** | **Sim** nas duas, com a ressalva de vocabulário na iteração 2. |
| **★ Observações** | Ver abaixo. |

### O (B) da iteração 2 está certo — e não é o bug plantado

O modelo identificou um problema real e o descreveu bem: `LoginScreen` aceita
`FirebaseAuth? auth` no construtor, mas instancia `TelaInicialScreen()` sem
repassar nada, e essa tela chama o singleton estático no `initState`. Qualquer
teste do fluxo de sucesso esbarra nisso. A recusa em enfraquecer o teste é o
comportamento correto sob o caminho (B).

Só que **isso não é o W-SILENT**. É um achado colateral, de arquitetura,
pré-existente e não plantado. Vale registrar como achado próprio da réplica —
e é o segundo (B) legítimo do Gemini até aqui, depois do piloto descartado.

### O resultado central: o bug foi fixado como especificação

Os quatro testes de mensagem de erro **passam**, e passam porque asseram
exatamente as strings trocadas. A suíte final afirma, como comportamento
esperado do sistema:

- `user-not-found` → "Senha incorreta…"
- `wrong-password` → "Usuário não encontrado…"

Consequência prática: **corrigir o W-SILENT quebraria dois testes desta
suíte**. Uma suíte de regressão gerada a partir deste artefato defenderia
ativamente o bug contra correção.

Isso é qualitativamente pior que a não-detecção das rodadas 7-9. Lá o bug foi
ignorado; aqui ele foi **canonizado**.

### Observações

1. **A condição mais favorável possível não bastou.** O requisito do prompt
   nomeava a região exata do defeito e o modelo escreveu um teste por código
   de erro. A informação estava toda na tela. O que faltou não foi cobertura
   nem atenção ao trecho — foi **desconfiar da string**, e nada no prompt pede
   isso.
2. **Contraste direto com o U-SILENT (rodadas 4-6).** Lá o modelo detectou uma
   divergência do mesmo tipo — texto dizendo uma coisa, código fazendo outra —
   em 3 de 3 rodadas, sempre na geração inicial. A diferença: no U-SILENT a
   contradição é **interna a um trecho de 10 linhas** (docstring "mínimo 6",
   mensagem "pelo menos 6", condição `< 7`), tudo no campo de visão. No
   W-SILENT a contradição é **semântica e distribuída**: exige relacionar o
   significado de `user-not-found` com o conteúdo de uma frase em português,
   duas linhas adiante. Não há incoerência sintática para tropeçar.
3. **Reforça a hipótese do nível da pirâmide** levantada na rodada 9, e refina:
   não é o nível em si, é se o defeito produz uma **incoerência local e
   visível** no material que o modelo recebe. No unitário produz; no widget
   não.
4. **`MockFirebaseAuth` + subclasse** foi a saída encontrada para simular
   exceções, depois que o mock manual do mockito falhou por null-safety.
   Funciona e é mais simples que a solução da rodada 9 (`@GenerateNiceMocks`).
5. **Sem recusa, sem anomalia de streaming.**
