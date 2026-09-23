# FASE2-UNIT-FS-08_formatName — Réplica Gemini

Rodada **38/60**. Bloco 2 (alvos limpos), lote 7 (`formatName`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-08_formatName |
| **Função/tela alvo** | `Validators.formatName` — **não é alvo limpo** (defeito real pré-existente: `RangeError` em `word[0]` com espaços múltiplos/nas pontas) |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/827bd30d374369d3` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/format_name_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-08_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-08_formatName.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/827bd30d374369d3` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 5 |
| **Testes passaram (1ª execução)** | **5/5** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |
| **Defeito `RangeError`** | **Detectado só em prosa** — nota "Atenção" após o código; nenhum teste exercita |

---

## Observações

1. Suíte verde de primeira: 5 testes, todos em entradas de espaço simples.
2. O modelo descreve o `RangeError` com precisão numa nota após o bloco de código, mas não escreve teste para ele. Suíte verde sem tocar no defeito — mesmo padrão das rodadas 16-17 (I-SILENT): visto e deixado de fora do teste.
3. ChatGPT na mesma rodada: 4 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('formatName', () {
    test('deve retornar string vazia quando o valor de entrada é vazio', () {
      expect(Validators.formatName(''), equals(''));
    });

    test('deve capitalizar a primeira letra de uma palavra única em minúsculo', () {
      expect(Validators.formatName('marcos'), equals('Marcos'));
    });

    test('deve manter a palavra capitalizada quando já inicia com maiúscula', () {
      expect(Validators.formatName('Marcos'), equals('Marcos'));
    });

    test('deve capitalizar a primeira letra de cada palavra em um nome composto', () {
      expect(Validators.formatName('joao silva'), equals('Joao Silva'));
    });

    test('deve funcionar corretamente com palavras de apenas uma letra', () {
      expect(Validators.formatName('a b c'), equals('A B C'));
    });
  });
}

```

> **Atenção:** Da forma como a função está implementada, chamadas com múltiplos espaços consecutivos (como `'joao  silva'`) ou espaços nas extremidades resultarão em erro de execução (`RangeError: index out of range` em `word[0]`), pois `split(' ')` gera strings vazias. Se quiser tornar a função mais resiliente a esses casos de borda e a letras maiúsculas misturadas no meio da palavra (ex.: `'jOAO'`), vale considerar refatorá-la para tratar palavras vazias e aplicar `.toLowerCase()` antes do `.substring(1)`.
````

