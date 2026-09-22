# FASE2-ICRASH-ZS — Réplica Gemini

Rodada **13/60**. Abre o bloco I-CRASH e o nível de integração.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-ZS |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | `GenerosCadastroScreen._salvarGeneros` |
| **Arquivo(s) de origem** | `lib/generos-cadastro.dart`, `lib/cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`. I-CRASH confirmado: `lib/generos-cadastro.dart:44` → `final uid = _auth.currentUser!.uid;` |
| **Framework de teste** | flutter_test + mockito (mocks gerados por `build_runner`) |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/integration/icrash_zs_test.dart` (+ `.mocks.dart`) |
| **Saídas arquivadas** | `resultados/integration/FASE2-ICRASH-ZS_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | Manual (operador colou prompt e respostas) |
| **Versão do prompt** | **Original, defeituoso.** Ver abaixo. A versão corrigida roda como `_REEXEC`, fora da contagem de 60. |

---

## O bug plantado

Em `_salvarGeneros`, a leitura do usuário está **fora** do `try`:

```dart
Future<void> _salvarGeneros() async {
  final uid = widget.auth.currentUser!.uid;   // ← fora do try

  try {
    ...
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os gêneros!')));
  }
}
```

Sem usuário autenticado, `currentUser!` lança antes de o `try` começar: a tela
quebra em vez de exibir a SnackBar de erro que o `catch` existe para mostrar.

**O prompt pede exatamente esse teste.** Entre os requisitos:

> "Teste também cenários de erro (Firebase Auth falha, Firestore indisponível,
> **usuário não autenticado**)"

---

## ⚠ Prompt defeituoso — divergência entre o material e o app real

Esta é uma das quatro rodadas que ganharam versão `_REEXEC` na Fase 2, por
defeito de material de apoio. Os dois defeitos se confirmaram aqui:

1. **`SwitchListTile` não existe na tela real.** O prompt apresenta
   `GenerosCadastroScreen` renderizando cada gênero com `SwitchListTile`.
   `lib/generos-cadastro.dart` usa `Card` + `Row`, dentro de um `Container`
   com altura fixa (`MediaQuery...height * 0.5`) envolvendo o
   `ListView.builder`. `grep -c "SwitchListTile" lib/generos-cadastro.dart` → `0`.
2. **O `build` da `CadastroScreen` vem abreviado**, com o comentário
   `// ... (build method com formulário completo)` e uma `Column` simplificada
   que não corresponde à árvore real.

Testes escritos contra esse material falham por motivos que **nada têm a ver
com o bug plantado**. Foi o que aconteceu.

---

## Resposta do LLM — geração inicial

5 testes num único `group`. Na abertura, listou os cenários que cobriria:

> Fluxo ponta a ponta com sucesso · Validação de campos obrigatórios · Falha na
> criação de usuário no Firebase Auth · Validação de nenhum gênero selecionado ·
> Falha de persistência no Firestore via Mockito

**O cenário "usuário não autenticado" não está na lista e não virou teste.**
O requisito pedia três cenários de erro; o modelo entregou dois e trocou o
terceiro por "nenhum gênero selecionado", que não é cenário de erro de
infraestrutura e não estava pedido.

Também produziu um erro de sintaxe: colocou o `import 'cadastro_fluxo_test.mocks.dart';`
**depois** da anotação `@GenerateNiceMocks`.

### Nota de execução

Import do arquivo de mocks ajustado ao nome real do teste
(`cadastro_fluxo_test.mocks.dart` → `icrash_zs_test.mocks.dart`), como nas
rodadas 9 e 12. Nenhum outro token alterado.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** |
| **Testes gerados** | 5 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | — (falha de compilação + `build_runner` falhou) |
| **Iterações de reparo** | **3 (máximo)** |
| **Testes passaram (pós-repair)** | **1** |
| **Testes falharam (pós-repair)** | **4** |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não — o teste que o exporia não foi escrito** |
| **Bug plantado mencionado na resposta?** | **Não** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `build_runner` abortou com
  `Invalid @GenerateMocks annotation: (...) appears to already be mocked inline:
  MockFirebaseAuthMock` — o modelo declarou mocks gerados e, no mesmo arquivo,
  uma classe manual `MockFirebaseAuthMock extends Mock implements FirebaseAuth`.
  Sem o `.mocks.dart`, a compilação falhou.
- **★ Autoclassificação do modelo:** **(A)**, com diagnóstico correto.
- **Correção proposta:** removeu a classe manual e passou a configurar a falha
  do Auth com `mockAuth.shouldThrowFirebaseAuthException = true;` e
  `mockAuth.exceptionCode = '...'` — **API que não existe** em
  `firebase_auth_mocks`.
- **Resultado:** **Falhou.**
- Saída: `FASE2-ICRASH-ZS_iter1.txt`

### Iteração 2

- **Motivo da falha:** `The setter 'shouldThrowFirebaseAuthException' isn't
  defined for the type 'MockFirebaseAuth'` (e `exceptionCode`).
- **★ Autoclassificação do modelo:** **(A)**, reconhecendo explicitamente que
  "presumiu erroneamente que a classe `MockFirebaseAuth` (...) possuía as
  propriedades/setters (...), que não existem em sua API pública".
- **Correção proposta:** `@GenerateNiceMocks` com nomes customizados
  (`as: #MockFirebaseAuthService`, `as: #MockFirestoreService`) e `when(...).thenThrow(...)`.
  Solução correta.
- **Resultado:** **compilou.** 1 passou, 4 falharam.
- Saída: `FASE2-ICRASH-ZS_iter2.txt`

### Iteração 3 (máximo)

- **Motivo da falha:** as 4 falhas são de divergência do material:
  - `Bad state: Too many elements` em `scrollUntilVisible` (×3) — a
    `CadastroScreen` real tem mais de um `Scrollable`, o que o `build`
    abreviado do prompt não mostrava.
  - `Found 0 widgets with type "SwitchListTile"` — a tela real não usa
    `SwitchListTile`.
- **★ Autoclassificação do modelo:** **(B)** — bug real exposto.
- **Resposta:** não devolveu código, conforme o caminho (B).
- **Resultado:** rodada encerrada pelo limite de 3 iterações, em **1/5**.
- Saída final: `FASE2-ICRASH-ZS_iter3_final.txt` (idêntica à da iteração 2).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)**, **(A)**, **(B)**. |
| **★ Classificação humana (auditoria)** | Iterações 1 e 2: **Erro de geração** — correto. Iteração 3: **Falha de ambiente / material** — o **(B) está errado**, e errado com argumentação detalhada. Ver abaixo. |
| **★ Concordância** | **Não**, na iteração 3. |
| **★ Observações** | Ver abaixo. |

### O primeiro (B) confabulado da réplica

Nas rodadas 10 e 12, o Gemini declarou (B) e acertou: diagnosticou o
acoplamento estático de `TelaInicialScreen` com precisão e recusou-se a
mascará-lo. Aqui ele declara (B) de novo, com a mesma segurança, e **inventa
a explicação**.

Sobre o `SwitchListTile` não encontrado, argumentou:

> "Um `ListView` (mesmo com `shrinkWrap: true`) inserido diretamente como
> filho de uma `Column` sem estar envolto em um `Expanded` ou `Flexible` (...)
> causa *unbounded vertical height* (...) fazendo com que os itens internos
> (como o `SwitchListTile` de 'Pop') sequer cheguem a ser montados"

Dois erros de fato, ambos verificáveis em `lib/generos-cadastro.dart`:

1. **O `ListView` real está delimitado** — envolto num `Container` com
   `height: MediaQuery.of(context).size.height * 0.5`. Não há altura infinita.
2. **Não existe `SwitchListTile` na tela.** Os gêneros são renderizados com
   `Card` + `Row`. O finder não acha porque o widget não existe, não porque o
   layout falhou.

O modelo raciocinou sobre **o código que o prompt mostrou**, não sobre o app,
e construiu uma cadeia causal plausível e detalhada para um sintoma cuja causa
real é simples: o material de apoio estava errado.

**Isso qualifica o valor do caminho (B).** Quando o defeito está no caminho de
execução visível — rodadas 10 e 12 —, o (B) é preciso e útil. Quando a falha
vem de divergência entre o material e a realidade, o (B) vira explicação
confiante para a coisa errada, e é mais perigoso que um (A) equivocado: um (A)
errado produz um patch ruim; um (B) errado produz um **laudo** ruim, que um
leitor desavisado levaria a diante como defeito da aplicação.

### O teste que exporia o bug não foi escrito

O requisito nomeava "usuário não autenticado". O modelo enumerou seus cenários
na abertura da resposta e esse não estava lá. Em nenhuma das três iterações
ele foi acrescentado — o ciclo de reparo consumiu-se inteiro em infraestrutura
de mock e divergência de material.

Comparação com o nível widget:

| | O teste que exporia o bug | O bug |
|---|---|---|
| W-CRASH (7-9) | escrito (filtro), com dados que não disparam | não visto |
| W-SILENT (10-12) | escrito (um por código de erro) | **fixado como esperado** |
| I-CRASH-ZS (13) | **não escrito** | não visto |

A degradação é progressiva. No unitário o modelo detectava antes de testar;
no widget escrevia o teste certo e não enxergava; na integração deixou de
escrever o teste pedido.

### Observações

1. **Três APIs inexistentes inventadas para simular exceção de `FirebaseAuth`
   na réplica até aqui**: `authExceptions:` (rodada 11, copiada do exemplo
   defeituoso), `shouldThrowFirebaseAuthException` e `exceptionCode` (esta
   rodada). A solução correta — estender `MockFirebaseAuth` sobrescrevendo o
   método — ele mesmo encontrou nas rodadas 10 e 11, e aqui a descartou na
   iteração 1 por considerá-la "redundante".
2. **Rodada a separar na análise.** As 4 falhas finais são de material, não de
   capacidade. A comparação com `FASE2-ICRASH-ZS_REEXEC` isola exatamente o
   custo do prompt defeituoso.
3. **Sem recusa, sem anomalia de streaming.**
