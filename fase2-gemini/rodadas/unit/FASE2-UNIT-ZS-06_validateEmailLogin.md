# FASE2-UNIT-ZS-06_validateEmailLogin — Réplica Gemini

Rodada **31/60**. Bloco 2 (alvos limpos), lote 5 (`validateEmailLogin`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-06_validateEmailLogin |
| **Função/tela alvo** | `Validators.validateEmailLogin` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/4637bff83b595cc3` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_email_login_zs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-ZS-06_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-06_validateEmailLogin.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/4637bff83b595cc3` | Resposta completa (a frase de abertura veio truncada e recomeçada; o bloco de código veio inteiro) |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 11 |
| **Testes passaram (1ª execução)** | **11/11** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |

---

## Observações

1. Suíte verde de primeira: 11 testes.
2. ChatGPT na mesma rodada: 16 testes, 12/16 na 1ª execução.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está o arquivo completo de testes unitários estrutAqui está o arquivo de testes unitários completo, estruturado com `flutter_test`, cobrindo cenários válidos, inválidos e casos de borda:

```dart
// test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    group('Falha - Campo vazio ou nulo', () {
      test('deve retornar mensagem de erro obrigatório quando o valor for null', () {
        final result = Validators.validateEmailLogin(null);
        expect(result, 'Por favor, insira seu e-mail');
      });

      test('deve retornar mensagem de erro obrigatório quando a string for vazia', () {
        final result = Validators.validateEmailLogin('');
        expect(result, 'Por favor, insira seu e-mail');
      });
    });

    group('Falha - Formato inválido e casos de borda', () {
      test('deve retornar erro para e-mail sem @', () {
        final result = Validators.validateEmailLogin('usuarioexemplo.com');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro para e-mail sem domínio/extensão', () {
        final result = Validators.validateEmailLogin('usuario@');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro para e-mail sem o ponto no domínio', () {
        final result = Validators.validateEmailLogin('usuario@dominio');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro para e-mail que começa diretamente com @', () {
        final result = Validators.validateEmailLogin('@dominio.com');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro se o ponto estiver colado ao @', () {
        final result = Validators.validateEmailLogin('usuario@.com');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro quando contiver apenas espaços em branco', () {
        // Como o regex exige r'^[^@]+@[^@]+\.[^@]+', apenas espaços falham no regex
        final result = Validators.validateEmailLogin('   ');
        expect(result, 'Por favor, insira um e-mail válido');
      });
    });

    group('Sucesso - Formatos válidos', () {
      test('deve retornar null para um e-mail padrão simples', () {
        final result = Validators.validateEmailLogin('teste@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com múltiplos subdomínios', () {
        final result = Validators.validateEmailLogin('usuario@sub.empresa.com.br');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail contendo números e caracteres comuns', () {
        final result = Validators.validateEmailLogin('usuario.123_abc@dominio.org');
        expect(result, isNull);
      });
    });
  });
}

```

### Como executar

Execute o comando no terminal a partir da raiz do projeto:

```bash
flutter test test/utils/validators_test.dart

```
````

