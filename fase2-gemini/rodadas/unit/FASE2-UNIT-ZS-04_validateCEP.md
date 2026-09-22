# FASE2-UNIT-ZS-04_validateCEP — Réplica Gemini

Rodada **25/60**. Bloco 2 (alvos limpos), lote 3 (`validateCEP`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-04_validateCEP |
| **Função/tela alvo** | `Validators.validateCEP` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — `gemini.google.com/app/956251a10eb6e4ab` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_cep_zs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-ZS-04_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-04_validateCEP.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/956251a10eb6e4ab` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 12 |
| **Testes passaram (1ª execução)** | **12/12** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |

---

## Observações

1. Suíte verde de primeira: 12 testes.
2. ChatGPT na mesma rodada: 16 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está a suíte de testes unitários para a função `validateCEP`, estruturada para o arquivo `test/utils/validators_test.dart` e pronta para execução via `flutter test`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators - validateCEP', () {
    group('Casos de Sucesso', () {
      test('deve retornar null para CEP válido no formato padrão', () {
        final result = Validators.validateCEP('50000-000');
        expect(result, isNull);
      });

      test('deve retornar null para outro CEP válido com dígitos variados', () {
        final result = Validators.validateCEP('01310-200');
        expect(result, isNull);
      });
    });

    group('Validação de Obrigatoriedade (Nulo / Vazio)', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for null', () {
        final result = Validators.validateCEP(null);
        expect(result, 'O CEP é obrigatório');
      });

      test('deve retornar mensagem de obrigatoriedade quando o valor for vazio', () {
        final result = Validators.validateCEP('');
        expect(result, 'O CEP é obrigatório');
      });
    });

    group('Validação de Formato e Casos de Borda', () {
      const invalidFormatMessage = 'CEP inválido. Formato correto: XXXXX-XXX';

      test('deve falhar para CEP sem hífen (apenas números)', () {
        final result = Validators.validateCEP('50000000');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com menos de 9 caracteres', () {
        final result = Validators.validateCEP('1234-567');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com mais de 9 caracteres', () {
        final result = Validators.validateCEP('123456-7890');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com hífen na posição incorreta', () {
        final result = Validators.validateCEP('1234-5678');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar quando contiver letras', () {
        final result = Validators.validateCEP('5000A-000');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar quando contiver caracteres especiais inválidos', () {
        final result = Validators.validateCEP('50000.000');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com espaços internos ou em branco', () {
        expect(Validators.validateCEP('   -   '), invalidFormatMessage);
        expect(Validators.validateCEP('50000 000'), invalidFormatMessage);
      });

      test('deve falhar para CEP válido com espaços extras nas pontas', () {
        // Como a função não aplica .trim(), deve acusar erro de tamanho/formato
        final result = Validators.validateCEP(' 50000-000 ');
        expect(result, invalidFormatMessage);
      });
    });
  });
}

```

### Como executar

No terminal, na raiz do projeto:

```bash
flutter test test/utils/validators_test.dart

```
````

