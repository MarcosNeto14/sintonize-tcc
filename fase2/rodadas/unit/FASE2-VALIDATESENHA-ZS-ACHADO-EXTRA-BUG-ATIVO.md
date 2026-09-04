# FASE2-VALIDATESENHA-ZS — ACHADO EXTRA (executada com o bug U-SILENT ainda ATIVO)

> ⚠️ **ESTA RODADA NÃO FAZ PARTE DA CONTAGEM DE 30 RODADAS LIMPAS.**
>
> Ela foi executada por engano contra o código **com o bug U-SILENT ainda
> injetado** em `validateSenha` (`value.length < 7` em vez de `< 6`), antes
> de a reversão dos bugs do piloto ter sido feita. O prompt usado foi o da
> rodada de controle limpo `FASE2-UNIT-ZS-02_validateSenha`, mas o alvo não
> estava limpo.
>
> A rodada oficial de controle limpo `FASE2-UNIT-ZS-02_validateSenha` foi
> refeita do zero, em conversa nova, **após** a reversão dos bugs.
>
> Esta documentação é preservada porque a rodada produziu um achado
> relevante por si só: detecção espontânea do bug U-SILENT na geração
> inicial, sem nenhuma falha nem ciclo de reparo — categoria **(C)**.
> Ver a nota do incidente em `fase2/propostas_bugs_fase2.md`.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO (fora da contagem oficial) |
| **Bug ID** | U-SILENT (ativo no momento da execução, sem intenção) |
| **Função testada** | `Validators.validateSenha` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 — atenção: a rodada `FASE2-UNIT-ZS-01` foi executada em 3.41.6; o ambiente foi atualizado entre as duas |
| **Arquivo de teste** | `test/fase2/unit/validate_senha_zs_ACHADO_EXTRA_BUG_ATIVO_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das 18 rodadas do piloto e das 4 reexecuções — não pelo autor manualmente no teclado |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-02_validateSenha.md`:
template zero-shot idêntico ao usado na Fase 1 (`prompts/PROMPT_TEMPLATE_UNIT.md`),
com o código da função colado verbatim — **incluindo, sem que se percebesse na
hora, o bug U-SILENT (`< 7`)**:

```dart
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 7) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 10 testes em 3 grupos (`Casos de falha`, `Casos de sucesso`,
`Casos de borda`) e, **ao final da resposta, sinalizou espontaneamente a
divergência entre a condição e a mensagem de erro** — isto é, o bug U-SILENT —
sem que nada no prompt pedisse por isso e antes de qualquer execução.

Frase exata da resposta do modelo (verbatim):

> Observação importante: há uma inconsistência entre a implementação e a mensagem de erro. A condição é value.length < 7, portanto 6 caracteres são rejeitados e 7 são aceitos, apesar da mensagem dizer “pelo menos 6 caracteres”. Os testes acima refletem o comportamento real da função.

Coerentemente com essa observação, os testes gerados assertam o comportamento
**real** (com bug), não o comportamento que a mensagem anuncia — em particular
os dois testes de fronteira:

- `'deve retornar mensagem de erro para senha com 6 caracteres'` → espera erro para `'123456'`
- `'deve rejeitar senha com exatamente 6 caracteres'` → espera erro para `'abcdef'`

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram (1ª execução)** | 10 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 10/10)

```
00:00 +10: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 10/10 na primeira execução, portanto nenhum prompt
de reparo foi enviado e nenhuma autoclassificação (A)/(B) foi solicitada ao
modelo. Conforme a "Nota sobre (C)" do
`fase2/Template_Documentacao_Rodada_Fase2.md`, (C) não é uma classificação de
reparo e a evidência é registrada diretamente na seção de autoclassificação
abaixo.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — bug identificado espontaneamente na geração inicial, sem falha nem reparo. Evidência: a "Observação importante" citada verbatim na seção "Resposta do LLM", em que o modelo nomeia a condição `value.length < 7`, aponta a contradição com a mensagem "pelo menos 6 caracteres", e declara que os testes refletem o comportamento real da função. |
| **★ Classificação humana (auditoria)** | Bug capturado sem necessidade de reparo (C) |
| **★ Concordância** | Sim |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Caso mais limpo de (C) observado até aqui no experimento.** Diferente das
   detecções espontâneas de I-CRASH e I-SILENT (que também ocorreram na
   resposta inicial), aqui a detecção não só aconteceu como **determinou o
   conteúdo das asserções**: o modelo escolheu deliberadamente assertar o
   comportamento com bug em vez do comportamento anunciado pela mensagem, e
   disse explicitamente que essa foi a escolha. O resultado é 10/10 sem
   reparo — um teste que documenta o bug em vez de falhar por causa dele.

2. **Consequência metodológica: um bug silencioso detectado dessa forma não
   aparece na métrica de "testes que falharam".** Se a análise só olhasse
   taxa de aprovação, esta rodada seria indistinguível de uma rodada sobre
   código correto (10/10, zero iterações). O achado só é visível no texto da
   resposta. Isso reforça a utilidade da categoria (C) introduzida na Fase 2
   e sugere que a taxa de aprovação, isolada, é uma métrica cega para bugs
   silenciosos.

3. **Contraste direto com o bloco U-SILENT do piloto.** Este mesmo bug, com
   este mesmo alvo, já havia sido rodado nas 3 estratégias no piloto
   (`FASE2-USILENT-{ZS,FS,COT}`). A comparação entre aquelas rodadas e esta é
   material de análise, com a ressalva de que os prompts não são idênticos
   (o prompt do piloto é o de `fase2/prompts_prontos/FASE2-USILENT-ZS.md`;
   o desta rodada é o de controle limpo, `FASE2-UNIT-ZS-02_validateSenha.md`).

4. **Este arquivo de teste só passa com o bug ativo.** Após a reversão do
   U-SILENT (`< 7` → `< 6`), os dois testes de fronteira listados acima
   passam a falhar, por construção. Isso é esperado e não deve ser
   "corrigido": o artefato registra o estado do código no momento da
   execução. O mesmo vale para os testes do piloto em
   `test/fase2/unit/{ucrash,usilent}_*_test.dart`.

---

**Referência de categorias (classificação humana — mesmas da Fase 1, + (C) da Fase 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
| Bug capturado sem necessidade de reparo (C) | O modelo já identificou e se ajustou ao bug real na geração inicial, sem falha nem ciclo de reparo |
