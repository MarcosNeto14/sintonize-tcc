# FASE2-ICRASH-FS — Réplica Gemini

Rodada **14/60**.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-FS |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | `GenerosCadastroScreen._salvarGeneros` |
| **Arquivo(s) de origem** | `lib/generos-cadastro.dart`, `lib/cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, I-CRASH ativo |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/integration/icrash_fs_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-ICRASH-FS_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | Manual |
| **Versão do prompt** | **Original, defeituoso.** Ver abaixo. |

---

## ⚠ O prompt mais divergente do conjunto

Esta rodada tem os três defeitos de material simultaneamente:

1. **Exemplo few-shot com API inexistente** — `MockFirebaseAuth(authExceptions: AuthExceptions(...))`.
2. **`SwitchListTile` que a tela real não usa** — `grep -c` em
   `lib/generos-cadastro.dart` → `0`.
3. **`CadastroScreen` com 4 campos quando a real tem 10** — o prompt mostra
   nome, e-mail, senha e confirmação; a tela real tem 12 ocorrências de
   campo, construídas por um helper `_buildTextField` mais um
   `_buildEstadoDropdown`.

Um quarto, que só ficou visível nesta rodada: **o prompt mostra
`Navigator.push(context, MaterialPageRoute(builder: (context) => GenerosCadastroScreen()))`,
sem repassar `auth` e `firestore`.** A `lib/cadastro.dart` real repassa:

```dart
// lib/cadastro.dart:162-170 — código real
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GenerosCadastroScreen(
      auth: widget.auth,
      firestore: widget.firestore,
    ),
  ),
);
```

Este prompt também **não traz a linha de ajuda do caminho de import**, como
todo FS, e **não pede o cenário "usuário não autenticado"** — não tem seção
de requisitos.

---

## Resposta do LLM — geração inicial

4 testes. Imports das telas **comentados**:

```dart
// Substitua pelos imports reais do seu projeto:
// import 'package:sintonize/cadastro.dart';
// import 'package:sintonize/generos-cadastro.dart';
```

Terceira rodada FS seguida travando em import — mas com comportamento
diferente da rodada 8 (três caminhos chutados) e igual à 11 (deixou
comentado, não tentou).

Observou por conta própria, na abertura da resposta, que "a `CadastroScreen`
instancia `GenerosCadastroScreen()` sem repassar explicitamente os parâmetros
`auth` e `firestore`" — a mesma classe de observação arquitetural que rendeu
os (B) corretos das rodadas 10 e 12. **Não ligou ao `currentUser!` fora do
`try`**, que está três linhas abaixo no código que recebeu.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** |
| **Testes gerados** | 4 |
| **Testes passaram (1ª execução)** | 0 |
| **Iterações de reparo** | **3 (máximo)** |
| **Testes passaram (pós-repair)** | **1** |
| **Testes falharam (pós-repair)** | **3** |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não** |
| **Bug plantado mencionado na resposta?** | **Não** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** `Method not found: 'CadastroScreen'` / `'GenerosCadastroScreen'`.
- **★ Autoclassificação:** **(A)**, correta — reconheceu que as linhas de
  import "haviam sido deixadas apenas como comentários ilustrativos".
- **Correção:** `import 'package:sintonize/cadastro.dart';` e
  `import 'package:sintonize/generos-cadastro.dart';` — **caminhos corretos,
  pela primeira vez numa rodada FS.**

  A explicação é visível no prompt: os blocos de código trazem
  `// ─── lib/cadastro.dart ───` e `// ─── lib/generos-cadastro.dart ───`
  como cabeçalho de seção. O caminho estava no material, como comentário.
  Nas rodadas 8 e 11 os prompts FS não tinham esse cabeçalho, e o modelo
  chutou ou desistiu.
- **Resultado:** compilou. **0/4** — todas as falhas do tipo
  `Found 0 widgets`.
- Saída: `FASE2-ICRASH-FS_iter1.txt`

### Iteração 2

- **Motivo:** 4 × "Found 0 widgets" — nenhum elemento descrito pelo prompt
  existe na tela real.
- **★ Autoclassificação:** **(A)**. Diagnosticou como problema de viewport
  (botão fora da tela de 800×600) e de animação de `SnackBar` (`pump()` em
  vez de `pumpAndSettle()`).
- **Correção:** `tester.view.physicalSize = Size(1080, 1920)`,
  `ensureVisible()` antes de cada tap, `pumpAndSettle()` no lugar de `pump()`,
  e tap em `find.text('Rock')` em vez de `find.widgetWithText(SwitchListTile, 'Rock')`.
- **Resultado:** **1/4.** O diagnóstico do `SnackBar` estava certo — o teste
  de "nenhum gênero selecionado" passou a passar.
- Saída: `FASE2-ICRASH-FS_iter2.txt`

### Iteração 3 (máximo)

- **Motivo:** 3 falhas restantes — validador de senha não exibe mensagem,
  `GenerosCadastroScreen` não encontrada após cadastro, `generos_favoritos`
  vem `[]`.
- **★ Autoclassificação:** **(B)** — bug real exposto. Não devolveu código.
- **Resultado:** rodada encerrada pelo limite, em **1/4**.
- Saída final: `FASE2-ICRASH-FS_iter3_final.txt`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)**, **(A)**, **(B)**. |
| **★ Classificação humana (auditoria)** | Iterações 1 e 2: **Erro de teste**, corretas. Iteração 3: **Falha de ambiente / material** — o **(B) está errado nos três pontos**. Ver abaixo. |
| **★ Concordância** | **Não**, na iteração 3. |
| **★ Observações** | Ver abaixo. |

### O (B) da iteração 3, ponto a ponto

**Diagnóstico 2 — o mais elaborado, e o mais instrutivo.** O modelo escreveu:

> "A `CadastroScreen` recebe `auth` e `firestore` injetáveis via construtor,
> mas na hora de navegar ela instancia `GenerosCadastroScreen()` sem repassar
> as instâncias recebidas"

E prescreveu a correção:

```dart
// Em lib/cadastro.dart:
Navigator.push(context, MaterialPageRoute(
  builder: (context) => GenerosCadastroScreen(
    auth: widget.auth, firestore: widget.firestore,
  ),
));
```

**Esse código já é exatamente o que `lib/cadastro.dart` faz.** A prescrição é
idêntica ao que existe no repositório. O modelo diagnosticou o snippet
simplificado do prompt e emitiu, com segurança, um laudo sobre um defeito que
a aplicação não tem — junto com um patch que a aplicação já aplicou.

**Diagnóstico 1** — atribui a ausência da mensagem de senha a uma
"ambiguidade de especificação" entre o validador de senha e o de confirmação.
O validador real é direto (`if (value.length < 6) return '...'`). A mensagem
não aparece porque a tela real tem 10 campos e a ordem/estrutura não é a do
prompt.

**Diagnóstico 3** — atribui o array vazio a `SwitchListTile` cujo tap no
título não alterna o valor. Não há `SwitchListTile` na tela.

**Os três diagnósticos são internamente coerentes e externamente falsos.**
Descrevem com precisão um aplicativo que existe apenas no prompt.

### O padrão do (B), agora com quatro casos

| Rodada | (B) declarado | Defeito diagnosticado | Existe no app? |
|---|---|---|---|
| 10 (WSILENT-ZS) | sim | `TelaInicialScreen` acopla `FirebaseAuth.instance` no `initState` | **sim** |
| 12 (WSILENT-COT) | sim | idem, em conversa independente | **sim** |
| 13 (ICRASH-ZS) | sim | `ListView` sem altura em `Column` | **não** |
| 14 (ICRASH-FS) | sim | `Navigator.push` sem injeção + 2 outros | **não** (o app já faz o que ele pede) |

O divisor não é a estratégia nem o nível: é **se o material do prompt
corresponde ao app**. Quando corresponde, o (B) é preciso e acionável. Quando
não corresponde, o modelo não tem como saber, e o (B) produz um laudo
confiante sobre software imaginário.

**Implicação prática para uso de LLM em teste:** o caminho (B) do prompt de
reparo — "não enfraqueça o teste, descreva o problema da aplicação" — é útil
apenas na medida em que o modelo enxerga a aplicação. Com material de apoio
desatualizado, ele converte o próprio erro em acusação contra o código, e a
acusação vem bem argumentada. Um revisor humano que confiasse nela abriria
issue para consertar o que já está certo.

### Observações

1. **O caminho de import veio do cabeçalho de comentário.** É a única rodada
   FS que acertou o import, e a única cujo prompt traz
   `// ─── lib/cadastro.dart ───` acima do código. Sugere que o modelo usa
   qualquer sinal textual de caminho disponível — não precisa ser instrução.
2. **O bug plantado nunca entrou em cena.** Sem requisito pedindo "usuário
   não autenticado" e sem o modelo tomar a iniciativa, `currentUser!` com
   `signedIn: false` nunca foi exercitado. Nos quatro testes, ou o usuário
   está logado, ou o fluxo não chega à `GenerosCadastroScreen`.
3. **Rodada a separar na análise**, junto com a 13. A comparação com os
   `_REEXEC` isola o custo do material defeituoso.
