# FASE2-UNIT-COT-07_validateEmailEdit — Réplica Gemini

Rodada **36/60**. Bloco 2 (alvos limpos), lote 6 (`validateEmailEdit`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-07_validateEmailEdit |
| **Função/tela alvo** | `Validators.validateEmailEdit` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/c323de5fac2a5dfc` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_email_edit_cot_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-COT-07_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/cot/FASE2-UNIT-COT-07_validateEmailEdit.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/c323de5fac2a5dfc` | Resposta completa |

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

1. Suíte verde de primeira: 16 testes (um deles com 3 `expect`).
2. ChatGPT na mesma rodada: 37 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
### 1. Análise da Função

A função `validateEmailEdit` é um validador de e-mail opcional (comum em formulários de edição de perfil), retornando `null` caso a entrada seja nula ou vazia. Quando um valor de texto não vazio é informado, ela valida a string contra uma expressão regular padrão de e-mail. Se o formato for incompatível com o padrão esperado, retorna a mensagem `'Formato de e-mail inválido'`.

---

### 2. Cenários de Teste

* **Cenários de Sucesso (entradas válidas / opcionais):**
* E-mail padrão comum (ex.: `usuario@dominio.com`).
* E-mail com subdomínio (ex.: `dev@mail.empresa.com.br`).
* E-mail com caracteres especiais permitidos no identificador (`.`, `_`, `%`, `+`, `-`).
* TLD longo ou moderno (ex.: `admin@startup.technology`).
* Valor nulo (`null`), garantindo que o campo seja opcional na edição.
* Valor vazio (`''`), permitindo limpar ou deixar o campo sem preenchimento.


* **Cenários de Falha (entradas com formato inválido):**
* Ausência do caractere `@` (ex.: `usuario.dominio.com`).
* Ausência do domínio após o `@` (ex.: `usuario@`).
* Ausência do identificador antes do `@` (ex.: `@dominio.com`).
* Ausência do TLD (ex.: `usuario@dominio`).
* TLD com menos de 2 caracteres (ex.: `usuario@dominio.c`).
* Espaços no início, meio ou fim (ex.: `usuario@dominio.com`).
* Caracteres proibidos na sintaxe (ex.: acentos ou símbolos como `!`, `#`, `$` fora da regra).


* **Casos de Borda:**
* String contendo apenas espaços em branco (`'   '`) — como `isNotEmpty` é verdadeiro, ela deve falhar na validação da regex.
* Múltiplos símbolos de `@` (ex.: `usuario@@dominio.com`).
* TLD exatamente no limite mínimo de 2 caracteres (ex.: `usuario@dominio.co` ou `br`).



---

### 3. Testes Unitários (`flutter_test`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    group('Cenários opcionais e valores vazios (deve retornar null)', () {
      test('deve retornar null quando o valor for nulo', () {
        final result = Validators.validateEmailEdit(null);
        expect(result, isNull);
      });

      test('deve retornar null quando o valor for uma string vazia', () {
        final result = Validators.validateEmailEdit('');
        expect(result, isNull);
      });
    });

    group('Cenários de sucesso com e-mails válidos (deve retornar null)', () {
      test('deve retornar null para um e-mail padrão simples', () {
        final result = Validators.validateEmailEdit('usuario@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com subdomínio e múltiplos pontos', () {
        final result = Validators.validateEmailEdit('dev@mail.empresa.com.br');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail contendo caracteres permitidos (._%+-) no identificador', () {
        final result = Validators.validateEmailEdit('user.name+tag_test-1@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com TLD longo/moderno', () {
        final result = Validators.validateEmailEdit('contato@empresa.technology');
        expect(result, isNull);
      });

      test('deve retornar null para TLD no limite mínimo de 2 caracteres', () {
        final result = Validators.validateEmailEdit('teste@dominio.io');
        expect(result, isNull);
      });
    });

    group('Cenários de falha com formatos inválidos (deve retornar mensagem de erro)', () {
      const errorMessage = 'Formato de e-mail inválido';

      test('deve retornar erro quando não contiver @', () {
        final result = Validators.validateEmailEdit('usuariodominio.com');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando faltar o identificador antes do @', () {
        final result = Validators.validateEmailEdit('@dominio.com');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando faltar o domínio após o @', () {
        final result = Validators.validateEmailEdit('usuario@');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando faltar o TLD', () {
        final result = Validators.validateEmailEdit('usuario@dominio');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando o TLD tiver menos de 2 caracteres', () {
        final result = Validators.validateEmailEdit('usuario@dominio.c');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando houver múltiplos @', () {
        final result = Validators.validateEmailEdit('usuario@@dominio.com');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando houver espaços antes, depois ou no meio', () {
        expect(Validators.validateEmailEdit(' usuario@dominio.com'), equals(errorMessage));
        expect(Validators.validateEmailEdit('usuario@dominio.com '), equals(errorMessage));
        expect(Validators.validateEmailEdit('user name@dominio.com'), equals(errorMessage));
      });

      test('deve retornar erro para string contendo apenas espaços em branco', () {
        final result = Validators.validateEmailEdit('   ');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando contiver caracteres especiais inválidos', () {
        final result = Validators.validateEmailEdit('usuário!#@dominio.com');
        expect(result, equals(errorMessage));
      });
    });
  });
}

```
````

