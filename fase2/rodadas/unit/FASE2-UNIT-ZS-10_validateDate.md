# FASE2-UNIT-ZS-10_validateDate — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-10 |
| **Função testada** | `Validators.validateDate` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_date_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateDate` não é alvo de nenhum bug plantado
da Fase 2. O código-fonte é byte-idêntico a `main`
(`git diff main -- lib/utils/validators.dart` vazio). Última das 8 funções
do grupo de rodadas limpas a ser testada em zero-shot — completa a
estratégia ZS para as 8 funções do escopo revisado.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-10_validateDate.md`,
template zero-shot idêntico ao usado na Fase 1.

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

Gerou 34 testes em 8 grupos (`quando a data é obrigatória`, `quando o
formato é inválido`, `quando os campos não são numéricos`, `quando o mês é
inválido`, `quando o dia é inválido`, `quando a data é válida`, `quando a
data está no futuro`, `casos de borda`).

Cobriu corretamente o cálculo de `maxDay` via `DateTime(year, month + 1,
0).day` para meses de 30/31 dias e para fevereiro, incluindo a regra de ano
bissexto completa (divisível por 4, exceção de séculos não divisíveis por
400 — testou `1900` como não-bissexto e `2000` como bissexto). Também
testou casos de borda específicos do comportamento real da função em vez de
presumir validação mais estrita do que a implementada: aceitou entradas sem
zero à esquerda (`'1/1/2000'`), ano de um dígito (`'01/01/1'`) e ano `0`,
todos válidos porque a função não impõe formato de largura fixa nem ano
mínimo — só usa `int.tryParse` e `DateTime`. Ao final, o modelo comentou
explicitamente essas duas sutilezas (aceitação de anos como `0` e ausência
de exigência de largura fixa dd/mm/aaaa) e observou que a comparação com
`DateTime.now()` nunca classifica a data de hoje como futura — coerente com
o uso pretendido (data de nascimento).

Resposta completa (código do arquivo de teste) reproduzida em
`test/fase2/unit/validate_date_zs_test.dart`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 34 |
| **Testes passaram (1ª execução)** | 34 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 34/34)

```
00:00 +33: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-10_validateDate_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 34/34 na primeira execução, portanto nenhum
prompt de reparo foi enviado e nenhuma autoclassificação (A)/(B)/(C) foi
solicitada — `validateDate` não carrega nenhum bug plantado nem exibe
comportamento divergente do especificado, então não há evidência de (C) a
registrar.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente para classificar |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário e não há bug a capturar) |
| **★ Observações** | Rodada limpa, sem incidentes. Encerra a estratégia zero-shot para as 8 funções do escopo revisado das 30 rodadas (unitário + widget + integração). Próximo passo: iniciar a estratégia few-shot (`FASE2-UNIT-FS-01_validateNome`). |

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
