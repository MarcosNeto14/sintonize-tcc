# FASE2-UNIT-COT-08_formatName — Réplica Gemini

Rodada **39/60**. Bloco 2 (alvos limpos), lote 7 (`formatName`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-08_formatName |
| **Função/tela alvo** | `Validators.formatName` — **não é alvo limpo** (defeito real pré-existente: `RangeError` em `word[0]` com espaços múltiplos/nas pontas) |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/281ebd751f99ce0d` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/format_name_cot_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-COT-08_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/cot/FASE2-UNIT-COT-08_formatName.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/281ebd751f99ce0d` | Resposta completa (a análise truncou e recomeçou antes do código; bloco de código inteiro) |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 9 |
| **Testes passaram (1ª execução)** | **9/9** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **1** |
| **Defeito `RangeError`** | **Detectado e canonizado** — 2 testes exigem `throwsA(isA<RangeError>())` |

---

## Observações

1. Suíte verde de primeira: 9 testes.
2. A análise (passo 1) já diz que a implementação "lança um erro em tempo de execução" com espaços extras; os passos 2-3 transformam isso em 2 testes que exigem o `RangeError`, sob o título "Comportamentos Inesperados da Implementação Atual". Chama de inesperado e fixa como esperado.
3. ChatGPT na mesma rodada: 15 testes, também com `throwsRangeError` (classificado (C) na Fase 2).

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
### 1. Análise da Função

A função ⁠`formatName` tem como objetivo capitalizar a primeira letra de cada palavra em### 1. Análise da Função

A função `formatName` recebe uma string, divide-a em palavras separadas por espaço e converte o primeiro caractere de cada palavra para maiúsculo, preservando o restante dos caracteres originais. Por não converter os caracteres subsequentes para minúsculo (`toLowerCase()`), ela preserva qualquer formatação interna existente. Além disso, a implementação atual lança um erro em tempo de execução (`RangeError`) caso encontre espaços consecutivos ou espaços nas extremidades, pois `word[0]` falha em strings vazias.

---

### 2. Cenários de Teste

* **Cenários de Sucesso (Entradas Válidas):**
* Nome simples com uma palavra minúscula (ex: `"joão"` $\rightarrow$ `"João"`).
* Nome composto padrão separado por espaço único (ex: `"maria da silva"` $\rightarrow$ `"Maria Da Silva"`).
* Palavras já capitalizadas (ex: `"Carlos Alberto"` $\rightarrow$ `"Carlos Alberto"`).
* Palavra com apenas um caractere (ex: `"a"` $\rightarrow$ `"A"`).


* **Casos de Borda e Limites:**
* String vazia (`""`): deve retornar a própria string vazia sem erros.
* Strings com caracteres especiais ou números no início (ex: `"123 teste"` $\rightarrow$ `"123 Teste"`).
* Preservação de maiúsculas existentes no meio das palavras (ex: `"mCDonald"` $\rightarrow$ `"MCDonald"`).


* **Cenários de Falha / Comportamentos Críticos (Entradas Inesperadas):**
* Espaços múltiplos consecutivos (ex: `"joao  silva"`): o `split(' ')` gera elementos vazios `""`, resultando em `RangeError` ao acessar `word[0]`.
* Espaços no início ou fim (ex: `" ana "`): também geram strings vazias no array, lançando `RangeError`.



---

### 3. Testes Unitários

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    group('Cenários de Sucesso (Entradas Válidas)', () {
      test('deve capitalizar uma única palavra minúscula', () {
        final result = Validators.formatName('joão');
        expect(result, equals('João'));
      });

      test('deve capitalizar todas as palavras de um nome composto com espaço simples', () {
        final result = Validators.formatName('maria da silva');
        expect(result, equals('Maria Da Silva'));
      });

      test('deve manter a formatação se as palavras já estiverem capitalizadas', () {
        final result = Validators.formatName('Carlos Alberto');
        expect(result, equals('Carlos Alberto'));
      });

      test('deve capitalizar palavra de apenas um caractere', () {
        final result = Validators.formatName('a b c');
        expect(result, equals('A B C'));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar string vazia sem erros quando receber string vazia', () {
        final result = Validators.formatName('');
        expect(result, equals(''));
      });

      test('deve manter números e caracteres especiais sem quebrar a execução', () {
        final result = Validators.formatName('123 teste');
        expect(result, equals('123 Teste'));
      });

      test('deve preservar letras maiúsculas internas da palavra', () {
        final result = Validators.formatName('mcDonald iPhone');
        expect(result, equals('McDonald IPhone'));
      });
    });

    group('Cenários de Falha / Comportamentos Inesperados da Implementação Atual', () {
      test('lança RangeError ao receber espaços no início ou fim', () {
        expect(
          () => Validators.formatName(' ana '),
          throwsA(isA<RangeError>()),
        );
      });

      test('lança RangeError ao receber múltiplos espaços consecutivos', () {
        expect(
          () => Validators.formatName('joao  silva'),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}

```
````

