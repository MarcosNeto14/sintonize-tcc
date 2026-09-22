# FASE2-UNIT-FS-04_validateCEP — Réplica Gemini

Rodada **26/60**. Bloco 2 (alvos limpos), lote 3 (`validateCEP`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-04_validateCEP |
| **Função/tela alvo** | `Validators.validateCEP` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — `gemini.google.com/app/0c24da08f576f7f2` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_cep_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-04_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-04_validateCEP.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/0c24da08f576f7f2` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução)** | **8/8** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |

---

## Observações

1. Resposta **truncada e recomeçada dentro do bloco de código** (o rascunho é cortado no meio de uma string, `'5000`, e um novo ```dart começa na mesma linha). Usada a versão final.
2. ChatGPT na mesma rodada: 7 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateCEP', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateCEP(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateCEP(''), isNotNull);
    });

    test('deve aceitar CEP com formato válido (XXXXX-XXX)', () {
      expect(Validators.validateCEP('50000-000'), isNull);
    });

    test('deve rejeitar CEP sem hífen', () {
      expect(Validators.validateCEP('50000000'), isNotNull);
    });

    test('deve rejeitar CEP com letras', () {
      expect(Validators.validateCEP('5000a-000'), isNotNull);
    });

    test('deve rejeitar CEP com menos dígitos que o padrão', () {
      expect(Validators.validateCEP('5000```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateCEP', () {
    test('deve retornar erro quando o valor for null', () {
      expect(Validators.validateCEP(null), isNotNull);
    });

    test('deve retornar erro quando o valor for vazio', () {
      expect(Validators.validateCEP(''), isNotNull);
    });

    test('deve aceitar CEP no formato correto XXXXX-XXX', () {
      expect(Validators.validateCEP('50000-000'), isNull);
    });

    test('deve rejeitar CEP com apenas 8 dígitos sem hífen', () {
      expect(Validators.validateCEP('50000000'), isNotNull);
    });

    test('deve rejeitar CEP com hífen na posição errada', () {
      expect(Validators.validateCEP('5000-0000'), isNotNull);
    });

    test('deve rejeitar CEP com caracteres alfabéticos ou especiais', () {
      expect(Validators.validateCEP('5000a-000'), isNotNull);
      expect(Validators.validateCEP('50000-00#'), isNotNull);
    });

    test('deve rejeitar CEP com tamanho menor que 9 caracteres', () {
      expect(Validators.validateCEP('1234-56'), isNotNull);
    });

    test('deve rejeitar CEP com tamanho maior que 9 caracteres', () {
      expect(Validators.validateCEP('50000-0001'), isNotNull);
    });
  });
}

```
````

