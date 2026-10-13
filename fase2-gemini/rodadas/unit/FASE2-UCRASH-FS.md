# FASE2-UCRASH-FS — Réplica Gemini

Rodada **2/60**.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-FS |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `Validators.capitalize` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada por rodada — ver `FASE2-UCRASH-ZS.md` e o README. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` ativo, conta logada. Print de sessão em `../../evidencias/2026-09-21_gemini_seletor_modelo_com_login_pro.png`. |
| **Data de acesso** | 2026-09-21 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, 6 bugs plantados ativos |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/ucrash_fs_test.dart` |
| **Saída arquivada** | `fase2-gemini/resultados/unit/FASE2-UCRASH-FS.txt` |

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-UCRASH-FS.md`, do separador
`---` em diante. Contém os dois exemplos few-shot (`validateCampoObrigatorio`
e `validateTelefone`) seguidos da função alvo.

---

## Resposta do LLM

````
Aqui estão os testes unitários estruturados com o pacote flutter_test, seguindo o padrão dos seus exemplos e cobrindo os casos de uso esperados para a função.

Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('capitalize', () {
    test('deve retornar string vazia quando o texto de entrada for vazio', () {
      expect(Validators.capitalize(''), equals(''));
    });

    test('deve capitalizar uma única palavra em minúsculas', () {
      expect(Validators.capitalize('joão'), equals('João'));
    });

    test('deve capitalizar uma única palavra em maiúsculas', () {
      expect(Validators.capitalize('MARIA'), equals('Maria'));
    });

    test('deve formatar texto com maiúsculas e minúsculas misturadas', () {
      expect(Validators.capitalize('maRIA silva'), equals('Maria Silva'));
    });

    test('deve formatar frase com múltiplas palavras', () {
      expect(
        Validators.capitalize('recife pernambuco brasil'),
        equals('Recife Pernambuco Brasil'),
      );
    });

    test('deve manter a formatação correta em palavras com apenas 1 caractere', () {
      expect(Validators.capitalize('a'), equals('A'));
      expect(Validators.capitalize('d e f'), equals('D E F'));
    });
  });
}
Observação importante sobre a implementação atual
Na implementação atual fornecida:

Dart
return text.split(' ').map((word) {
  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}).join(' ');
Se o texto contiver espaços múltiplos consecutivos (ex.: 'Maria  Silva') ou espaços nas extremidades (ex.: ' Maria'), o split(' ') produzirá substrings vazias (""), gerando um erro de índice em tempo de execução (RangeError: Index out of range: index should be less than 0: 0 ao tentar acessar word[0]).

Caso precise que a função trate palavras vazias geradas por múltiplos espaços (conforme mencionado no comentário da documentação), você pode ajustar a implementação com uma verificação de word.isEmpty:

Dart
static String capitalize(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
Com esse ajuste, é possível adicionar também o teste para espaços consecutivos:

Dart
test('deve preservar múltiplos espaços sem lançar exceção', () {
  expect(Validators.capitalize('maria  silva'), equals('Maria  Silva'));
});
````

### Decisão de operação — o que foi para o arquivo

Foi salvo **apenas o bloco `void main()`**, a suíte que o modelo entregou
como resposta à tarefa. O teste final (`'deve preservar múltiplos espaços sem
lançar exceção'`) **não foi incluído**: o próprio modelo o condiciona a
alterar a implementação antes ("Com esse ajuste, é possível adicionar
também..."), e alterar `lib/` é proibido pelo protocolo. Incluí-lo produziria
uma falha fabricada pelo operador, não pelo modelo.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | 6 |
| **Testes falharam (1ª execução)** | 0 |
| **Iterações de reparo** | 0 |
| **Bug plantado capturado por asserção?** | **Não** |

### Saída do terminal

```
00:00 +0: loading test/fase2-gemini/unit/ucrash_fs_test.dart
00:00 +1: capitalize deve capitalizar uma única palavra em minúsculas
00:00 +2: capitalize deve capitalizar uma única palavra em maiúsculas
00:00 +3: capitalize deve formatar texto com maiúsculas e minúsculas misturadas
00:00 +4: capitalize deve formatar frase com múltiplas palavras
00:00 +5: capitalize deve manter a formatação correta em palavras com apenas 1 caractere
00:00 +6: All tests passed!
```

Saída completa em `../../resultados/unit/FASE2-UCRASH-FS.txt`.

---

## Iterative Repair Loop

**Não houve.** Nenhum teste falhou, ciclo não acionado.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — o modelo reconheceu o U-CRASH na geração inicial, descreveu o `RangeError` e a causa (`split(' ')` gerando strings vazias) e propôs a guarda `if (word.isEmpty)`. Não houve falha nem reparo. |
| **★ Classificação humana (auditoria)** | **Bug capturado sem necessidade de reparo (C)** — porém **apenas em prosa**. Ver a ressalva abaixo. |
| **★ Concordância** | **Sim**, quanto à categoria. |
| **★ Observações** | Ver abaixo. |

### Ressalva — (C) em prosa, não em asserção

Este (C) é **materialmente mais fraco que o da rodada ZS**, e a diferença
precisa aparecer na análise:

| | ZS (rodada 1) | FS (rodada 2) |
|---|---|---|
| Reconheceu o bug em texto | sim | sim |
| Propôs a guarda `word.isEmpty` | sim | sim |
| **Asserções que capturam o bug** | **3** (`throwsA(isA<RangeError>())`) | **0** |
| Entradas que disparam o bug na suíte | 3 | nenhuma |
| Resultado | 11/11 | 6/6 |

Ambas as suítes passam 100%, e **é justamente aí que a métrica de aprovação
engana**: a suíte ZS passa *porque documenta o bug*; a suíte FS passa *porque
desvia dele*. Uma regressão que corrigisse o U-CRASH quebraria a suíte ZS
(sinal correto, teste de caracterização) e passaria despercebida pela FS.

### Observações

1. **Hipótese sobre o efeito do few-shot.** Os dois exemplos do prompt usam
   exclusivamente o padrão `expect(..., isNull)` / `isNotNull` de validadores
   que retornam `String?`. Nenhum demonstra `throwsA`, exceções ou
   comportamento de crash. A suíte gerada não usa `throwsA` em nenhum ponto,
   apesar de o modelo ter identificado uma exceção no mesmo turno. É
   plausível que os exemplos tenham ancorado o **vocabulário de asserção** e
   afastado o teste de exceção. Verificar se o mesmo padrão se repete em
   U-SILENT-FS, W-CRASH-FS e I-CRASH-FS antes de tratar como achado.
2. **Cobertura menor.** 6 testes contra 11 da ZS, sem casos de borda com
   símbolos, números ou acentos.
3. **O modelo leu o código, não a docstring** — como na ZS. Citou o comentário
   "trata palavras vazias" e apontou que a implementação não faz isso.
4. **Comparação com a Fase 2 (ChatGPT):** `fase2/resultados/unit/FASE2-UCRASH-FS_iter0.txt`.
