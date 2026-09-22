# FASE2-UNIT-FS-03_validateNumero — Réplica Gemini

Rodada **23/60**. Bloco 2 (alvos limpos), lote 2 (`validateNumero`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-03_validateNumero |
| **Função/tela alvo** | `Validators.validateNumero` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — `gemini.google.com/app/d9ef8452b77e23c1` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_numero_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-03_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-03_validateNumero.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/d9ef8452b77e23c1` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | **6/6** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |

---

## Observações

1. Seis testes, espelhando a estrutura enxuta do exemplo few-shot; não testa espaços, e por isso não caiu na premissa das rodadas 22 e 24.
2. ChatGPT na mesma rodada: 4 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNumero', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNumero(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNumero(''), isNotNull);
    });

    test('deve rejeitar valor que contém letras ou caracteres especiais', () {
      expect(Validators.validateNumero('12a4'), isNotNull);
      expect(Validators.validateNumero('12#4'), isNotNull);
    });

    test('deve rejeitar valor com casas decimais', () {
      expect(Validators.validateNumero('12.5'), isNotNull);
    });

    test('deve retornar null quando valor é um número inteiro válido', () {
      expect(Validators.validateNumero('123'), isNull);
    });

    test('deve retornar null quando valor é zero ou número negativo válido', () {
      expect(Validators.validateNumero('0'), isNull);
      expect(Validators.validateNumero('-10'), isNull);
    });
  });
}

```
````

