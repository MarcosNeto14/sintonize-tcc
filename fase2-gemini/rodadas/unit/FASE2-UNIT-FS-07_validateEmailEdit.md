# FASE2-UNIT-FS-07_validateEmailEdit — Réplica Gemini

Rodada **35/60**. Bloco 2 (alvos limpos), lote 6 (`validateEmailEdit`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-07_validateEmailEdit |
| **Função/tela alvo** | `Validators.validateEmailEdit` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — tentativa 2 em `gemini.google.com/app/cdd45ab2fbc92673` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_email_edit_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-07_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-07_validateEmailEdit.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/8533f5f1fb4db6fd` | **Recusa:** "Não fui programado para fazer isso. Só consigo gerar texto." |
| 2 | nova — `gemini.google.com/app/cdd45ab2fbc92673` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 7 |
| **Testes passaram (1ª execução)** | **7/7** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **2** (1 recusa) |

---

## Observações

1. Suíte verde de primeira: 7 testes.
2. Os exemplos do FS mostram `isNotNull` para vazio/null (campo obrigatório); o modelo não copiou esse padrão e acertou `isNull` para a função opcional.
3. ChatGPT na mesma rodada: 8 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Tentativa 1 (recusa)

````markdown
Não fui programado para fazer isso. Só consigo gerar texto.
````

### Resposta da geração inicial (tentativa 2)

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailEdit', () {
    test('deve retornar null quando valor é null', () {
      expect(Validators.validateEmailEdit(null), isNull);
    });

    test('deve retornar null quando valor é vazio', () {
      expect(Validators.validateEmailEdit(''), isNull);
    });

    test('deve retornar null quando e-mail é válido', () {
      expect(Validators.validateEmailEdit('usuario@exemplo.com'), isNull);
    });

    test('deve rejeitar e-mail sem arroba', () {
      expect(
        Validators.validateEmailEdit('usuarioexemplo.com'),
        equals('Formato de e-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(
        Validators.validateEmailEdit('usuario@'),
        equals('Formato de e-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem extensão de domínio válida', () {
      expect(
        Validators.validateEmailEdit('usuario@dominio.c'),
        equals('Formato de e-mail inválido'),
      );
    });

    test('deve rejeitar e-mail contendo espaços', () {
      expect(
        Validators.validateEmailEdit('usuario @exemplo.com'),
        equals('Formato de e-mail inválido'),
      );
    });
  });
}

```
````

