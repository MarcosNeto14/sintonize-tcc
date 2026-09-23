# FASE2-UNIT-FS-10_validateDate — Réplica Gemini

Rodada **41/60**. Bloco 2 (alvos limpos), lote 8 (`validateDate`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-10_validateDate |
| **Função/tela alvo** | `Validators.validateDate` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/26c0cb65c49f3087` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_date_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-10_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-10_validateDate.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/26c0cb65c49f3087` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 9 |
| **Testes passaram (1ª execução)** | **9/9** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |

---

## Observações

1. Suíte verde de primeira: 9 testes, vários com mais de um `expect`.
2. Único FS do bloco 2 a seguir literalmente o `isNotNull` dos exemplos: nenhuma asserção confere a mensagem retornada, então os 6 ramos de erro são indistinguíveis para a suíte.
3. ChatGPT na mesma rodada: 14 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateDate', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateDate(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateDate(''), isNotNull);
    });

    test('deve rejeitar quando formato não contém três partes separadas por barra', () {
      expect(Validators.validateDate('10-05-1995'), isNotNull);
      expect(Validators.validateDate('10/05'), isNotNull);
    });

    test('deve rejeitar quando contém caracteres não numéricos', () {
      expect(Validators.validateDate('aa/05/1995'), isNotNull);
      expect(Validators.validateDate('10/bb/1995'), isNotNull);
      expect(Validators.validateDate('10/05/aaaa'), isNotNull);
    });

    test('deve rejeitar mês menor que 01 ou maior que 12', () {
      expect(Validators.validateDate('10/00/1995'), isNotNull);
      expect(Validators.validateDate('10/13/1995'), isNotNull);
    });

    test('deve rejeitar dia menor que 01 ou maior que o limite do mês', () {
      expect(Validators.validateDate('00/05/1995'), isNotNull);
      expect(Validators.validateDate('32/01/1995'), isNotNull);
      expect(Validators.validateDate('31/04/1995'), isNotNull); // Abril tem 30 dias
    });

    test('deve respeitar anos bissextos para o mês de fevereiro', () {
      expect(Validators.validateDate('29/02/2024'), isNull); // 2024 é bissexto
      expect(Validators.validateDate('29/02/2023'), isNotNull); // 2023 não é bissexto
    });

    test('deve rejeitar datas no futuro', () {
      final anoFuturo = DateTime.now().year + 5;
      expect(Validators.validateDate('01/01/$anoFuturo'), isNotNull);
    });

    test('deve retornar null quando a data for válida e no passado', () {
      expect(Validators.validateDate('15/08/1998'), isNull);
    });
  });
}

```
````

