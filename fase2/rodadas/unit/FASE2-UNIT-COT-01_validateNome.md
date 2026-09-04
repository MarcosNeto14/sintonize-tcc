# FASE2-UNIT-COT-01_validateNome — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-01 |
| **Função testada** | `Validators.validateNome` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_nome_cot_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateNome` não é alvo de nenhum bug
plantado da Fase 2. Primeira função da estratégia chain-of-thought no
escopo revisado de 8 funções.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/cot/FASE2-UNIT-COT-01_validateNome.md`
— prompt estruturado em 3 passos (analisar, identificar cenários, escrever
testes).

```dart
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    final hasInvalidCharacters = RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
    if (hasInvalidCharacters) {
      return 'O nome não pode conter números ou caracteres especiais';
    }
    return null;
  }
```

---

## Resposta do LLM

Seguiu rigorosamente a estrutura pedida: (1) análise da função em 3
frases; (2) lista explícita de cenários de sucesso, falha e borda antes de
qualquer código; (3) 21 testes organizados em 3 grupos aninhados
(`Cenários de sucesso`, `Cenários de falha`, `Casos de borda`) dentro de
`group('Validators.validateNome', ...)`.

Ponto notável: a análise de cenários **previu corretamente**, antes de
escrever qualquer teste, que `\s` no regex inclui tabulação e quebra de
linha ("pela implementação atual, é considerado válido" / "\\s permite
esses caracteres, portanto são aceitos") e escreveu os testes
`validateNome('\t')` e `validateNome('\n')` esperando `isNull` — o
comportamento correto. Isso contrasta diretamente com
`FASE2-UNIT-ZS-01_validateNome` (mesma função, zero-shot, rodada 1 desta
série), em que o modelo presumiu o oposto (que `\s` excluiria esses
caracteres) e precisou de 1 iteração de reparo após 2 falhas.

Também identificou corretamente que uma string cyrillica (`'Алексей'`) cai
fora do intervalo Unicode `À-ÿ` e deve ser rejeitada, e que espaço puro
(`'   '`) é tecnicamente válido pela implementação (não passa pela guarda
`isEmpty`, e os espaços são aceitos pelo `\s`).

O código foi obtido via clipboard (botão "copiar" do bloco de código) para
garantir fidelidade exata dos espaços no teste
`'João   da   Silva'` (3 espaços entre cada palavra) — `get_page_text`
colapsa espaços consecutivos ao extrair texto de elementos HTML, então a
extração de texto puro não é confiável para este tipo de conteúdo.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 21 |
| **Testes passaram (1ª execução)** | 21 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 21/21)

```
00:00 +21: All tests passed!
```

(saída completa em `fase2/resultados/unit/cot/FASE2-UNIT-COT-01_validateNome_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 21/21 na primeira execução.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente do especificado a classificar; o comportamento de `\s` (incluindo tabulação/quebra de linha) foi corretamente antecipado, não é um bug |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário) |
| **★ Observações** | Dado mais direto desta rodada para a comparação ZS vs. CoT: mesma função, mesmo comportamento de fronteira (`\s` incluindo `\t`/`\n`), zero-shot presumiu errado e precisou de reparo, chain-of-thought raciocinou sobre a regex antes de escrever o teste e acertou de primeira. Consistente com a hipótese de que o passo explícito de "identificar cenários" antes de codificar reduz presunções incorretas sobre a semântica de classes de regex. |

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
