# FASE2-UNIT-FS-01_validateNome — Réplica Gemini

Rodada **20/60**. Bloco 2 (alvos limpos), lote 1 (`validateNome`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-01_validateNome |
| **Função/tela alvo** | `Validators.validateNome` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — tentativa 2 em `gemini.google.com/app/7b2a3780378eabaf` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_nome_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-01_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-01_validateNome.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/83820e74a9dc3274` | **Recusa:** "Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho capacidade de entender e responder a essa questão." |
| 2 | nova — `gemini.google.com/app/7b2a3780378eabaf` | Resposta completa |

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

1. Resposta **truncada e recomeçada dentro do bloco de código** (o rascunho é cortado no terceiro teste e um novo ```dart começa colado na mesma linha). Usada a versão final, como nas rodadas anteriores; a primeira extração, com as duas partes coladas, não compilava e foi descartada antes de qualquer reparo — não é iteração.
2. ChatGPT na mesma rodada: 6 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Tentativa 1 (recusa)

````markdown
Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho capacidade de entender e responder a essa questão.
````

### Resposta da geração inicial (tentativa 2)

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNome', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateNome(null),
        equals('O nome é obrigatório'),
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateNome(''),
        equals('O nome é obrigatório'),
      );
    });

    test('deve rejeitar nome contendo números', () {```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNome', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNome(null), 'O nome é obrigatório');
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNome(''), 'O nome é obrigatório');
    });

    test('deve rejeitar nome contendo números', () {
      expect(
        Validators.validateNome('Marcos 123'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });

    test('deve rejeitar nome contendo caracteres especiais e símbolos', () {
      expect(
        Validators.validateNome('João @ Silva'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });

    test('deve aceitar nome simples válido', () {
      expect(Validators.validateNome('Marcos'), isNull);
    });

    test('deve aceitar nome composto com espaços', () {
      expect(Validators.validateNome('Ana Clara Silva'), isNull);
    });

    test('deve aceitar nomes com acentuação e cedilha', () {
      expect(Validators.validateNome('Ágatha José Lourenço Müller'), isNull);
    });
  });
}

```
````

