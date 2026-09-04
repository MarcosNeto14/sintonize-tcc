# FASE2-UNIT-COT-10_validateDate — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-10 |
| **Função testada** | `Validators.validateDate` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_date_cot_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateDate` não é alvo de nenhum bug
plantado da Fase 2. Última das 8 funções do escopo revisado a ser testada
em chain-of-thought — completa a estratégia CoT.

**Nota de infraestrutura:** durante o envio do prompt de reparo, o
clipboard do sistema foi sobrescrito por conteúdo externo
(`admin@unigas.com.br`, aparentemente de um autofill do navegador) entre a
cópia do texto e o paste. Detectado antes do envio (o campo de texto
continha um valor visivelmente incorreto), corrigido recopiando e colando
imediatamente antes do envio. Não afetou o conteúdo enviado ao modelo.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/cot/FASE2-UNIT-COT-10_validateDate.md`
— prompt estruturado em 3 passos (analisar, identificar cenários, escrever
testes).

```dart
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Análise e lista de cenários (7 sucesso, 15 falha, 7 borda) antes do
código. Gerou 31 testes em 6 grupos, incluindo cálculo correto de
`maxDay` para múltiplos meses, ano bissexto completo (regra de século),
data futura calculada dinamicamente com `DateTime.now().add(...)`, e o
comportamento do ano `0000` (aceito, sem validação explícita de faixa de
ano). Um teste presumiu incorretamente que `int.tryParse` rejeitaria
espaços nas extremidades da string (`' 15/05/1990 '`), esperando a
mensagem de erro — mesma classe de erro já observada em
`FASE2-UNIT-COT-03_validateNumero` desta série, mas aqui aplicada a
`validateDate`.

### Iteração 1 (repair)

- **Motivo da falha:** `validateDate(' 15/05/1990 ')` retornou `null`
  (válido), pois `int.tryParse` tolera espaços ao redor de cada
  componente (`' 15'`, `'1990 '`), mas o teste esperava a mensagem de erro
  de campos não numéricos.
- **Prompt de reparo enviado:** conforme
  `fase2/prompts_prontos/unit/cot/FASE2-UNIT-COT-10_validateDate.md`, com
  a saída completa do `flutter test`.
- **Resposta do LLM:** classificou explicitamente **(A)** — "o teste
  presume um comportamento que não é especificado" — com raciocínio
  correto sobre `int.tryParse`. Moveu o teste do grupo "campos não
  numéricos" para "Casos de borda", invertendo a expectativa para
  `isNull` e renomeando para refletir o comportamento real
  ("deve aceitar espaços nas extremidades da data"). Adicionou uma nota
  de rigor metodológico: se a rejeição de espaços fosse um requisito de
  negócio já definido, a classificação correta seria (B) e a correção
  deveria ocorrer na implementação, não no teste — mas como não há tal
  requisito documentado, manteve (A).
- **Resultado após correção:** Passou (32/32).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 31 (iteração 0) → 32 (iteração 1, um teste reclassificado sem remoção líquida) |
| **Testes passaram (1ª execução)** | 30 |
| **Testes falharam (1ª execução)** | 1 |
| **Testes passaram (pós-repair)** | 32 |
| **Testes falharam (pós-repair)** | 0 |

### Saída do terminal (iteração 0)

```
00:00 +17 -1: ... deve retornar erro quando houver espaços na entrada [E]
  Expected: 'Data inválida. Certifique-se de que todos os campos são números'
    Actual: <null>
...
00:00 +31 -1: Some tests failed.
```

(saída completa em `fase2/resultados/unit/cot/FASE2-UNIT-COT-10_validateDate_iter0.txt`)

### Saída do terminal (iteração 1 — final, 32/32)

```
00:00 +32: All tests passed!
```

(saída completa em `fase2/resultados/unit/cot/FASE2-UNIT-COT-10_validateDate_iter1_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** presunção incorreta de que `int.tryParse`
  rejeitaria espaços ao redor dos componentes numéricos da data.
- **Prompt de reparo enviado:** saída completa do `flutter test` (1 falha).
- **Resposta do LLM:** classificação explícita **(A)**; teste
  reclassificado de "falha" para "borda", com expectativa corrigida para
  `isNull`.
- **Resultado após correção:** Passou (32/32).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) — declarada explicitamente e corretamente |
| **★ Classificação humana (auditoria)** | Erro de teste — confirmado: `int.tryParse` tolera espaço em branco ao redor do número, comportamento documentado da biblioteca padrão do Dart; a implementação não tem culpa nesse ponto |
| **★ Concordância** | Sim |
| **★ Observações** | Segunda ocorrência do mesmo padrão de erro nesta série CoT (a primeira foi em `FASE2-UNIT-COT-03_validateNumero`, mesma sessão): o modelo presume que `int.tryParse` é estrito quanto a espaços em branco, quando na verdade tolera. É um erro sistemático e específico de conhecimento sobre a API padrão do Dart, não de raciocínio sobre a lógica da função — reforça a hipótese, já levantada em `FASE2-UNIT-COT-03`, de que esse é um ponto cego recorrente do modelo independentemente da função testada, desde que ela use `int.tryParse` sobre uma entrada que pode conter espaços. Encerra a estratégia chain-of-thought para as 8 funções do escopo revisado (rodadas 17–24/30). Próximo passo: widget `CadastroScreen` × ZS/FS/COT. |

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
