# FASE2-UNIT-FS-05_validateEmail — Réplica Gemini

Rodada **29/60**. Bloco 2 (alvos limpos), lote 4 (`validateEmail`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-05_validateEmail |
| **Função/tela alvo** | `Validators.validateEmail` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/3875f05e6f0840a8` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_email_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-05_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-05_validateEmail.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/3875f05e6f0840a8` | Resposta completa |

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

1. Suíte verde de primeira: 8 testes, no formato dos exemplos, mas com `equals(<mensagem>)` no lugar do `isNotNull` dos exemplos.
2. ChatGPT na mesma rodada: 9 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateEmail(null),
        equals('O e-mail é obrigatório'),
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateEmail(''),
        equals('O e-mail é obrigatório'),
      );
    });

    test('deve rejeitar e-mail sem @', () {
      expect(
        Validators.validateEmail('usuarioemail.com'),
        equals('E-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem domínio após o @', () {
      expect(
        Validators.validateEmail('usuario@'),
        equals('E-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem TLD válido', () {
      expect(
        Validators.validateEmail('usuario@dominio'),
        equals('E-mail inválido'),
      );
    });

    test('deve rejeitar e-mail com espaços', () {
      expect(
        Validators.validateEmail('usuario @dominio.com'),
        equals('E-mail inválido'),
      );
    });

    test('deve retornar null para e-mail padrão válido', () {
      expect(
        Validators.validateEmail('usuario@dominio.com'),
        isNull,
      );
    });

    test('deve retornar null para e-mail com subdomínio e caracteres especiais permitidos', () {
      expect(
        Validators.validateEmail('user.name+tag@sub.dominio.com.br'),
        isNull,
      );
    });
  });
}

```
````

