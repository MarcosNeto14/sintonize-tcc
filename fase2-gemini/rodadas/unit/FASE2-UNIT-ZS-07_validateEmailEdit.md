# FASE2-UNIT-ZS-07_validateEmailEdit — Réplica Gemini

Rodada **34/60**. Bloco 2 (alvos limpos), lote 6 (`validateEmailEdit`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-07_validateEmailEdit |
| **Função/tela alvo** | `Validators.validateEmailEdit` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/895fc96ae8af33af` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_email_edit_zs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-ZS-07_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-07_validateEmailEdit.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/895fc96ae8af33af` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 16 |
| **Testes passaram (1ª execução)** | **16/16** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |

---

## Observações

1. Suíte verde de primeira: 16 testes. Cobre corretamente o caráter opcional (null e vazio → null).
2. ChatGPT na mesma rodada: 20 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está o arquivo de testes unitários completo, estruturado com `flutter_test`, cobrindo cenários válidos, inválidos e casos de borda para a função `validateEmailEdit`.

Crie o arquivo em `test/utils/validators_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators - validateEmailEdit', () {
    group('Casos opcionais / borda neutra (devem retornar null)', () {
      test('deve retornar null quando o valor for nulo', () {
        final result = Validators.validateEmailEdit(null);
        expect(result, isNull);
      });

      test('deve retornar null quando a string for vazia', () {
        final result = Validators.validateEmailEdit('');
        expect(result, isNull);
      });
    });

    group('E-mails válidos (devem retornar null)', () {
      test('deve aceitar e-mail em formato padrão simples', () {
        final result = Validators.validateEmailEdit('usuario@exemplo.com');
        expect(result, isNull);
      });

      test('deve aceitar subdomínios', () {
        final result = Validators.validateEmailEdit('usuario@mail.empresa.com.br');
        expect(result, isNull);
      });

      test('deve aceitar caracteres especiais permitidos no local-part (+, _, %, -, .)', () {
        final result = Validators.validateEmailEdit('user.name+tag_123%test-456@dominio.org');
        expect(result, isNull);
      });

      test('deve aceitar TLDs longos com mais de 2 caracteres', () {
        final result = Validators.validateEmailEdit('dev@plataforma.technology');
        expect(result, isNull);
      });

      test('deve aceitar letras maiúsculas e minúsculas', () {
        final result = Validators.validateEmailEdit('User.Name@Domain.COM');
        expect(result, isNull);
      });
    });

    group('E-mails inválidos (devem retornar mensagem de erro)', () {
      const errorMessage = 'Formato de e-mail inválido';

      test('deve rejeitar e-mail sem arroba (@)', () {
        final result = Validators.validateEmailEdit('usuarioexemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail sem domínio após o @', () {
        final result = Validators.validateEmailEdit('usuario@');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail sem parte local antes do @', () {
        final result = Validators.validateEmailEdit('@exemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail sem TLD / extensão final', () {
        final result = Validators.validateEmailEdit('usuario@dominio');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar TLD com menos de 2 caracteres', () {
        final result = Validators.validateEmailEdit('usuario@dominio.c');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail contendo espaços internos', () {
        final result = Validators.validateEmailEdit('user name@exemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail com espaços no início ou fim (sem trim prévio)', () {
        final result = Validators.validateEmailEdit(' usuario@exemplo.com ');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar múltiplos arrobas (@)', () {
        final result = Validators.validateEmailEdit('usuario@@exemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar caracteres especiais proibidos', () {
        final result = Validators.validateEmailEdit('usuario!#\$@dominio.com');
        expect(result, equals(errorMessage));
      });
    });
  });
}

```

### Como executar

Execute no terminal na raiz do projeto:

```bash
flutter test test/utils/validators_test.dart

```

Ou execute toda a suíte de testes do projeto:

```bash
flutter test

```
````

