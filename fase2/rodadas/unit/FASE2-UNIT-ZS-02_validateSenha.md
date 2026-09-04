# FASE2-UNIT-ZS-02_validateSenha — Documentação da Rodada

> **Nota de execução:** esta rodada foi **refeita do zero, em conversa nova**,
> após a reversão dos bugs U-SILENT/U-CRASH. Uma execução anterior, feita por
> engano contra o código com o U-SILENT ainda ativo, está preservada — fora da
> contagem de 30 — em
> `fase2/rodadas/unit/FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO.md`.
> O incidente está registrado em `fase2/propostas_bugs_fase2.md`.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-02 |
| **Função testada** | `Validators.validateSenha` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 — a rodada `FASE2-UNIT-ZS-01` rodou em 3.41.6; o ambiente foi atualizado entre as duas |
| **Arquivo de teste** | `test/fase2/unit/validate_senha_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das 18 rodadas do piloto e das 4 reexecuções — não pelo autor manualmente no teclado |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-02_validateSenha.md`:
código isolado da função `validateSenha` (sem docstring), template zero-shot
idêntico ao usado na Fase 1 (`prompts/PROMPT_TEMPLATE_UNIT.md`). Código colado
verbatim, já no estado limpo (`value.length < 6`):

```dart
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 8 testes em 2 grupos (`Falhas de validação`, `Sucesso de
validação`). Não criou um terceiro grupo explícito de "casos de borda" — como
haviam feito as rodadas anteriores — mas cobriu a fronteira dentro do grupo de
sucesso, com o caso de exatamente 6 caracteres, e encerrou a resposta chamando
atenção para ele:

> O caso de exatamente 6 caracteres é especialmente importante porque testa o limite da condição value.length < 6.

Cobertura entregue: `null`, string vazia, 5 caracteres, 1 caractere,
exatamente 6, mais de 6, mistura de letras/números/símbolos, e senha contendo
espaço (`'abc 12'`).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução)** | 8 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 8/8)

```
00:00 +8: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-02_validateSenha_iter0_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Necessária?** Não. A suíte passou 8/8 na primeira execução; nenhum prompt de reparo foi enviado e nenhuma autoclassificação (A)/(B) foi solicitada ao modelo.

### Iteração 2

- **Necessária?** Não.

### Iteração 3

- **Necessária?** Não.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Não declarada — não houve falha, portanto não houve ciclo de reparo em que o esquema (A)/(B) fosse solicitado. Também não se aplica (C): não há bug nesta função após a reversão, logo não há bug a ser capturado espontaneamente. |
| **★ Classificação humana (auditoria)** | N/A — nenhuma falha a classificar |
| **★ Concordância** | N/A (repair não foi necessário e não havia bug a capturar) |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Rodada limpa, sem incidentes.** Função pura, sem Firebase, widget ou
   viewport. O modelo acertou a fronteira (`'123456'` → válido) de primeira,
   que é exatamente o ponto em que o bug U-SILENT do piloto se manifestava.

2. **Contraste direto e controlado com o achado extra.** O mesmo prompt, na
   mesma estratégia, sobre a mesma função, produziu conjuntos de asserções
   opostos na fronteira conforme o código apresentado: com o bug ativo, o
   modelo assertou `'123456'` → *erro* e sinalizou a inconsistência
   explicitamente na resposta; sem o bug, assertou `'123456'` → `null`. Nos
   dois casos o teste refletiu o comportamento real do código que lhe foi
   dado, e nos dois casos a suíte passou 100% sem reparo. É evidência de que
   o modelo estava lendo a implementação fornecida, e não reproduzindo um
   template genérico de "validador de senha de 6 caracteres" — o que fortalece
   a leitura de (C) atribuída ao achado extra.

3. **Menor cobertura que a rodada 1.** 8 testes contra 19 de
   `FASE2-UNIT-ZS-01` (validateNome), coerente com a superfície muito menor da
   função (dois ramos de erro, um de sucesso, sem regex). O modelo dispensou o
   grupo "Casos de borda" que vinha usando, embutindo o caso de fronteira no
   grupo de sucesso — divergência de forma em relação ao requisito "inclua
   casos de borda", ainda que o conteúdo esteja coberto.

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
