# FASE2-UNIT-FS-06_validateEmailLogin — Réplica Gemini

Rodada **32/60**. Bloco 2 (alvos limpos), lote 5 (`validateEmailLogin`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-06_validateEmailLogin |
| **Função/tela alvo** | `Validators.validateEmailLogin` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/5b52c50399457737` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_email_login_fs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-FS-06_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/few-shot/FASE2-UNIT-FS-06_validateEmailLogin.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/5b52c50399457737` | Resposta completa, truncada e recomeçada dentro do bloco de código; usada a versão final |

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

1. Suíte verde de primeira: 8 testes.
2. A resposta truncou no terceiro teste e recomeçou; o texto copiado traz as duas partes (Apêndice). Arquivo de teste = versão recomeçada, a única completa.
3. ChatGPT na mesma rodada: 6 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailLogin', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateEmailLogin(null),
        'Por favor, insira seu e-mail',
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateEmailLogin(''),
        'Por favor, insira seu e-mail',
      );
    });

    test('deve retornar mensagem de erro quando formato do e-mail não contém @', () {
      expect(
        Validators.validateEmailLogin('usuarioemail.com'),
        'Por favor, insira um e-mail válido```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailLogin', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateEmailLogin(null), 'Por favor, insira seu e-mail');
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateEmailLogin(''), 'Por favor, insira seu e-mail');
    });

    test('deve rejeitar e-mail sem arroba (@)', () {
      expect(
        Validators.validateEmailLogin('usuario.dominio.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve rejeitar e-mail sem domínio ou extensão', () {
      expect(
        Validators.validateEmailLogin('usuario@dominio'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve rejeitar e-mail com múltiplos arrobas (@)', () {
      expect(
        Validators.validateEmailLogin('usuario@@dominio.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve rejeitar e-mail sem nome de usuário antes do arroba', () {
      expect(
        Validators.validateEmailLogin('@dominio.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve retornar null quando o e-mail é válido', () {
      expect(Validators.validateEmailLogin('usuario@email.com'), isNull);
    });

    test('deve retornar null para e-mails válidos com subdomínios', () {
      expect(Validators.validateEmailLogin('contato@empresa.com.br'), isNull);
    });
  });
}

```
````

