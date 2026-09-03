# FASE2-ICRASH-FS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-FS |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | Fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` + `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/integration/icrash_fs_test.dart` |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-ICRASH-FS.md` — prompt Few-shot: um
exemplo completo de teste de integração de um fluxo de login (com
`AuthExceptions`, API que **não existe** em `firebase_auth_mocks` 0.14.x —
armadilha herdada do próprio exemplo), seguido do pedido real para o fluxo
`CadastroScreen → GenerosCadastroScreen` com o bug I-CRASH embutido.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta"):

```
Abaixo está um teste de integração focado no fluxo completo, usando firebase_auth_mocks
e fake_cloud_firestore. Há dois cenários: sucesso ao salvar os gêneros e tentativa de
confirmar sem selecionar nenhum gênero.

[2 testWidgets(): 'fluxo completo: cadastro, seleção de gêneros e salvamento no
Firestore' e 'não permite confirmar sem selecionar um gênero'. Usa MockFirebaseAuth
+ FakeFirebaseFirestore, find.byType(SwitchListTile).]

Observação importante

No primeiro teste, o ponto mais importante é verificar não apenas a navegação, mas
também o estado final do Firestore:

CadastroScreen cria o usuário no Firebase Auth.
O documento usuarios/{uid} é criado.
A navegação chega à GenerosCadastroScreen.
Rock e Jazz são selecionados.
Confirmar executa o update.
O teste consulta o FakeFirebaseFirestore e confirma que generos_favoritos contém
exatamente os gêneros selecionados.
A navegação para TelaInicialScreen também é validada.

Há ainda um detalhe no código fornecido: GenerosCadastroScreen usa
widget.auth.currentUser!.uid, portanto é essencial passar a mesma instância de
MockFirebaseAuth para a tela — o teste faz isso.

Se TelaInicialScreen estiver em outro arquivo, basta adicionar o respectivo import; o
teste acima assume que ela está disponível pelos imports existentes do projeto.
```

**★ Detecção espontânea do bug-alvo:** **não** — diferente da rodada
Zero-shot (FASE2-ICRASH-ZS), esta resposta menciona `currentUser!.uid`
apenas para justificar a necessidade de reutilizar a mesma instância de
`MockFirebaseAuth`, sem observar que o acesso ocorre **fora do `try`** nem
propor um cenário de usuário não autenticado.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `Undefined name 'TelaInicialScreen'` (import ausente) |
| **Testes gerados** | 2 |
| **Iteração 1** | Compilou. **0 passaram / 2 falharam** (`scrollUntilVisible` com erro de estado + `SwitchListTile` inexistente) |
| **Iteração 2** | **0 passaram / 2 falharam** (tap fora do viewport + `scrollable: find.byType(ListView)` incompatível com a assinatura da API) |
| **Iteração 3 (final, máximo permitido)** | **0 passaram / 2 falharam** |

### Saída do terminal (iteração 0 — falha de compilação)

Ver `fase2/resultados/integration/FASE2-ICRASH-FS_iter0.txt`

```
test/fase2/integration/icrash_fs_test.dart:79:28: Error: Undefined name 'TelaInicialScreen'.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
                           ^^^^^^^^^^^^^^^^^
00:00 +0 -1: Some tests failed.
```

### Saída do terminal (iteração 1 — 0/2)

Ver `fase2/resultados/integration/FASE2-ICRASH-FS_iter1.txt`

```
Bad state: Too many elements
  em WidgetController.scrollUntilVisible (linha 56: scrollUntilVisible(botaoCadastrar, 300))

Expected: exactly 7 matching candidates
  Actual: _TypeWidgetFinder:<Found 4 widgets with type "Switch">
```

### Saída do terminal (iteração 2 — 0/2)

Ver `fase2/resultados/integration/FASE2-ICRASH-FS_iter2.txt`

```
Warning: A call to tap() with finder "... ElevatedButton ... 'Cadastrar'" derived an
Offset (Offset(400.0, 870.0)) that would not hit test on the specified widget.
Indeed, Offset(400.0, 870.0) is outside the bounds of the root of the render tree,
Size(800.0, 600.0).
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "GenerosCadastroScreen": []>

type 'ListView' is not a subtype of type 'Scrollable' in type cast
  em scrollUntilVisible(..., scrollable: find.byType(ListView))
```

### Saída do terminal (iteração 3 — final, 0/2, máximo de reparos atingido)

Ver `fase2/resultados/integration/FASE2-ICRASH-FS_iter3_final.txt`

```
Expected: exactly 4 matching candidates
  Actual: _TypeWidgetFinder:<Found 10 widgets with type "TextFormField">
   Which: is too many

Expected: exactly 7 matching candidates
  Actual: _TypeWidgetFinder:<Found 4 widgets with type "Switch">
   Which: is not enough
```

---

## ★ Achado metodológico importante

### 1. O prompt Few-shot contém um `CadastroScreen` simplificado com 4 campos; o app real tem 10

`fase2/prompts_prontos/FASE2-ICRASH-FS.md` embute um `CadastroScreen`
reduzido (`nome`, `email`, `senha`, `confSenha` — 4 `TextFormField`). O
app real (`lib/cadastro.dart`) usa um helper `_buildTextField()` chamado
10 vezes (nome, data de nascimento, e-mail, senha, confirmação de senha,
CEP, rua, número, bairro, cidade — mais o `DropdownButtonFormField` de
estado). `grep -c "TextFormField("` no arquivo real retorna 1 ocorrência
literal (o `_buildTextField` interno), mas em runtime produz 10 widgets
`TextFormField`, exatamente o número relatado por `flutter test` na
iteração final. É a **mesma classe de divergência** já registrada em
`FASE2-ICRASH-ZS.md` (lá, era `SwitchListTile` vs `Switch`) — desta vez
afetando a tela de cadastro, não a de gêneros. Ambos os prompts prontos
para o bug I-CRASH (ZS e FS) fornecem versões resumidas do código-fonte
que não correspondem ao artefato real, o que penaliza sistematicamente
a taxa de sucesso dos testes nesta dupla de rodadas, independente da
qualidade do raciocínio do modelo.

### 2. `tester.binding.setSurfaceSize()` não resolveu a limitação de altura do `ListView.builder`

Na iteração final, o próprio modelo propôs
`tester.binding.setSurfaceSize(const Size(800, 1400))` para tornar todo o
fluxo visível sem scroll — a mesma técnica documentada como eficaz em
rodadas anteriores (ver `feedback_fase2_...` e o achado de W-SILENT/W-CRASH
sobre viewport). Desta vez, apenas 4 dos 7 `Switch` foram materializados
mesmo com o viewport ampliado. A causa mais provável, consistente com os
números observados: `GenerosCadastroScreen` dimensiona a lista com
`Container(height: MediaQuery.of(context).size.height * 0.5)`; se
`MediaQuery.of(context).size` continuar refletindo o tamanho padrão do
`TestViewConfiguration` (800×600) em vez do tamanho definido por
`setSurfaceSize()` — o que pode ocorrer dependendo de como a API se
relaciona com `tester.view` nesta versão do Flutter — a altura do
container permanece `300` (`600 × 0.5`), o que comporta exatamente ~4
cards de ~76px de altura. Essa hipótese não foi verificada de forma
independente (não há mais iterações de reparo disponíveis nesta rodada),
mas é totalmente consistente com o número relatado e com o padrão já
registrado de lacunas de conhecimento do modelo sobre APIs de teste do
Flutter em mudança entre versões.

### 3. Nenhuma iteração restante para corrigir a divergência de 10 campos

A divergência do item 1 só foi conhecida na saída da iteração 3 (a
última permitida), então não houve oportunidade de corrigi-la dentro do
protocolo. O resultado final documentado é **0/2**.

---

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo:** erro de compilação (`Undefined name 'TelaInicialScreen'`)
+ o `build()` real de `GenerosCadastroScreen` (usa `Switch`, não
`SwitchListTile`) + aviso sobre o viewport padrão 800×600 + template (A)/(B).
Ver `scratchpad/r14_repair1.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A) — o teste presumiu um símbolo disponível sem importar
TelaInicialScreen e também presumiu uma implementação de UI (SwitchListTile)
diferente da implementação real. Isso é um problema do teste, não uma evidência
de comportamento incorreto da aplicação.

Segue o arquivo completo corrigido, sem alterar o código da aplicação. Também
incluí ensureVisible/scrollUntilVisible para lidar com o viewport padrão de
flutter_test.
```

**Ação:** adicionou o import, trocou `SwitchListTile` por `Switch`, usou
`ensureVisible()`/`scrollUntilVisible()`.
**Resultado:** compilou; falhou em runtime (`Bad state: Too many elements`
em `scrollUntilVisible`, e apenas 4/7 `Switch` materializados).

### Iteração 2

**Prompt de reparo:** as 2 falhas de runtime + hipóteses de causa
(`scrollUntilVisible` pode estar inferindo um `Scrollable` ambíguo;
`ListView.builder` é lazy) + template (A)/(B). Ver `scratchpad/r14_repair2.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A) — ambas as falhas são causadas por suposições/estratégias
inadequadas do teste diante da implementação real e do comportamento lazy do
ListView.builder. Não há, nesses erros, evidência de comportamento incorreto da
aplicação.

A correção abaixo evita scrollUntilVisible no formulário de cadastro quando o
botão já está acessível e, na tela de gêneros, rola explicitamente o ListView
para materializar os itens antes de interagir com eles.
```

**Ação:** removeu `scrollUntilVisible` do formulário de cadastro (assumindo que
o botão já estaria acessível), passou a usar `find.ancestor`/`find.descendant`
para localizar o `Switch` de um gênero específico, e usou
`scrollUntilVisible(..., scrollable: find.byType(ListView))` na tela de
gêneros.
**Resultado:** o botão "Cadastrar" continuou fora do viewport (tap em
`Offset(400, 870)`, fora de `Size(800, 600)`) — a suposição de que "já
estaria acessível" estava errada; e `scrollable: find.byType(ListView)`
lançou erro de tipo, pois o parâmetro exige um `Finder<Scrollable>`.

### Iteração 3 (final — máximo permitido)

**Prompt de reparo:** as 2 causas técnicas exatas identificadas (viewport
insuficiente; incompatibilidade de tipo em `scrollable:`) + sugestão de usar
`tester.binding.setSurfaceSize()` como alternativa mais robusta + aviso de
última iteração. Ver `scratchpad/r14_repair3.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A) — as duas falhas são causadas pelo próprio teste: o viewport
padrão é insuficiente para o botão Cadastrar, e scrollable: recebeu um Finder de
ListView em vez de um Finder de Scrollable. Não há evidência, nesses erros, de
comportamento incorreto da aplicação.

Nesta última correção, uso tester.binding.setSurfaceSize(const Size(800, 1400))
para tornar o fluxo determinístico e eliminar a necessidade de rolagem.
```

**Ação:** adotou `tester.binding.setSurfaceSize(const Size(800, 1400))` com
`try/finally` para restaurar o tamanho padrão, e passou a esperar
`findsNWidgets(4)` para os campos e `findsNWidgets(7)` para os `Switch`.
**Resultado final:** **0/2** — `findsNWidgets(4)` encontrou 10 (divergência
de prompt vs. app real, achado 1) e `findsNWidgets(7)` encontrou apenas 4
(limitação da técnica `setSurfaceSize`, achado 2). Máximo de iterações
atingido — documentado como está, por protocolo.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas 3 iterações — sempre atribuiu as falhas a suposições incorretas do próprio teste, nunca a um comportamento incorreto da aplicação |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de teste** corrigido corretamente (import + `Switch`), mas a correção introduziu um **Erro de geração** novo (`scrollUntilVisible` mal utilizado). Iteração 2: **Erro de geração** (suposição não verificada de que o botão já seria visível; API `scrollable:` usada com tipo incompatível). Iteração 3: **Limitação de testabilidade / falha de ambiente** — a divergência de 10 vs. 4 campos é **falha do material do prompt**, não do teste ou da aplicação; a limitação de `setSurfaceSize` com `MediaQuery`-driven sizing é consistente com uma **lacuna de API específica de versão do Flutter**, não com um bug do app |
| **★ Concordância** | Discorda parcialmente. A classificação (A) do modelo é defensável nas 3 iterações — de fato não há evidência de bug na aplicação em nenhuma das falhas — mas a causa raiz de duas das falhas remanescentes (10 vs. 4 campos) não é "o teste presumiu algo errado" no sentido comum: é uma consequência direta de o **material de entrada da rodada** (prompt) descrever uma tela simplificada. O modelo não tinha como saber disso e não pode ser responsabilizado por essa parte |
| **★ Observações** | Nenhuma detecção espontânea do bug I-CRASH nesta rodada (ao contrário da ZS), e o resultado final ficou em **0/2** — pior do que a rodada ZS (1/6) em taxa relativa, embora com menos testes gerados. As 3 iterações foram consumidas inteiramente por problemas de infraestrutura de teste (import ausente, viewport, tipo de `Scrollable`), sem nunca alcançar o cenário de usuário não autenticado que expôs o bug na rodada ZS. Reforça o achado de que a estratégia Few-shot, ao fornecer um exemplo de domínio diferente (login em vez de cadastro), não induziu neste caso nem a detecção espontânea do bug nem uma cobertura de cenários de erro tão ampla quanto a Zero-shot produziu nesta mesma dupla de telas. |

### Categorias de classificação humana

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
