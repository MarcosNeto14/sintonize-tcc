# FASE2-UNIT-FS-10_validateDate — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-10 |
| **Função testada** | `Validators.validateDate` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_date_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateDate` não é alvo de nenhum bug plantado
da Fase 2. Última das 8 funções do escopo revisado a ser testada em
few-shot — completa a estratégia FS.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/few-shot/FASE2-UNIT-FS-10_validateDate.md`
— mesmos dois exemplos padrão seguidos do corpo verbatim de `validateDate`.

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

Gerou 14 testes em um único grupo, cobrindo obrigatoriedade, formato,
campos não numéricos, limites de mês, limites de dia (incluindo mês de 30
dias), ano bissexto (2024 aceito, 2023 rejeitado em 29/02), data futura e
data de hoje. Para o teste de data futura, o modelo **usou a data absoluta
corrente do ambiente** (`'05/09/2026'`, comentando explicitamente que essa
é "amanhã em relação à data atual (04/09/2026)") em vez de calcular
`DateTime.now().add(...)` como fez a rodada zero-shot equivalente — uma
escolha determinística, porém frágil a re-execuções em datas futuras (o
teste deixará de ser "amanhã" e poderá falhar caso o ambiente de teste não
compartilhe a mesma noção de "hoje" usada pelo modelo). Encerrou apontando
corretamente que a função aceita formatos sem zero à esquerda (`'1/2/2000'`)
por não validar largura fixa de dígitos.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 14 |
| **Testes passaram (1ª execução)** | 14 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 14/14)

```
00:00 +14: All tests passed!
```

(saída completa em `fase2/resultados/unit/few-shot/FASE2-UNIT-FS-10_validateDate_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 14/14 na primeira execução.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente para classificar |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário e não há bug a capturar) |
| **★ Observações** | Encerra a estratégia few-shot para as 8 funções do escopo revisado (rodadas 9–16/30). Ponto de atenção para reprodutibilidade futura: o teste `'deve rejeitar data futura'` usa a data absoluta `'05/09/2026'` em vez de uma data relativa (`DateTime.now().add(...)`) — deixará de representar "amanhã" em execuções futuras da suíte, embora ainda passe hoje. Próximo passo: iniciar a estratégia chain-of-thought (`FASE2-UNIT-COT-01_validateNome`). |

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
