# Dados Consolidados — Experimento TCC Sintonize

**Experimento:** Comparação ZS × FS × COT para geração automatizada de testes Flutter via LLM (GPT-5.5)  
**Data de consolidação:** 2026-05-25  
**Total de rodadas:** 48 (30 unit + 9 widget + 9 integration)

---

## 1. Testes Unitários (30 rodadas)

> Todas as 30 rodadas compilaram na 1ª execução. Após repair loop, **0 falhas** em todas as rodadas.  
> Coluna **Pass(1ª)** = testes que passaram sem nenhum reparo.

| ID | Estratégia | Função | Gerados | Pass(1ª) | Fail(1ª) | Pass(final) | Fail(final) | Iterações |
|---|---|---|---|---|---|---|---|---|
| UNIT-ZS-01 | ZS | validateNome | 12 | 12 | 0 | 12 | 0 | 0 |
| UNIT-ZS-02 | ZS | validateSenha | 7 | 7 | 0 | 7 | 0 | 0 |
| UNIT-ZS-03 | ZS | validateNumero | 10 | 9 | 1 | 10 | 0 | 1 |
| UNIT-ZS-04 | ZS | validateCEP | 10 | 10 | 0 | 10 | 0 | 0 |
| UNIT-ZS-05 | ZS | validateEmail | 14 | 14 | 0 | 14 | 0 | 0 |
| UNIT-ZS-06 | ZS | validateEmailLogin | 11 | 11 | 0 | 11 | 0 | 0 |
| UNIT-ZS-07 | ZS | validateEmailEdit | 13 | 13 | 0 | 13 | 0 | 0 |
| UNIT-ZS-08 | ZS | formatName | 10 | 8 | 2 | 10 | 0 | 1 |
| UNIT-ZS-09 | ZS | capitalize | 10 | 10 | 0 | 10 | 0 | 0 |
| UNIT-ZS-10 | ZS | validateDate | 19 | 19 | 0 | 19 | 0 | 0 |
| UNIT-FS-01 | FS | validateNome | 6 | 6 | 0 | 6 | 0 | 0 |
| UNIT-FS-02 | FS | validateSenha | 5 | 5 | 0 | 5 | 0 | 0 |
| UNIT-FS-03 | FS | validateNumero | 6 | 6 | 0 | 6 | 0 | 0 |
| UNIT-FS-04 | FS | validateCEP | 7 | 7 | 0 | 7 | 0 | 0 |
| UNIT-FS-05 | FS | validateEmail | 10 | 10 | 0 | 10 | 0 | 0 |
| UNIT-FS-06 | FS | validateEmailLogin | 7 | 7 | 0 | 7 | 0 | 0 |
| UNIT-FS-07 | FS | validateEmailEdit | 10 | 10 | 0 | 10 | 0 | 0 |
| UNIT-FS-08 | FS | formatName | 7 | 6 | 1 | 7 | 0 | 1 |
| UNIT-FS-09 | FS | capitalize | 8 | 8 | 0 | 8 | 0 | 0 |
| UNIT-FS-10 | FS | validateDate | 13 | 13 | 0 | 13 | 0 | 0 |
| UNIT-COT-01 | COT | validateNome | 10 | 10 | 0 | 10 | 0 | 0 |
| UNIT-COT-02 | COT | validateSenha | 9 | 9 | 0 | 9 | 0 | 0 |
| UNIT-COT-03 | COT | validateNumero | 10 | 9 | 1 | 10 | 0 | 1 |
| UNIT-COT-04 | COT | validateCEP | 11 | 11 | 0 | 11 | 0 | 0 |
| UNIT-COT-05 | COT | validateEmail | 12 | 12 | 0 | 12 | 0 | 0 |
| UNIT-COT-06 | COT | validateEmailLogin | 13 | 13 | 0 | 13 | 0 | 0 |
| UNIT-COT-07 | COT | validateEmailEdit | 11 | 11 | 0 | 11 | 0 | 0 |
| UNIT-COT-08 | COT | formatName | 12 | 8 | 4 | 12 | 0 | 2 |
| UNIT-COT-09 | COT | capitalize | 10 | 10 | 0 | 10 | 0 | 0 |
| UNIT-COT-10 | COT | validateDate | 15 | 15 | 0 | 15 | 0 | 0 |

### Resumo UNIT por estratégia

| Estratégia | Gerados | Pass(1ª) | Fail(1ª) | Pass(final) | Fail(final) | Rodadas c/ repair | Total iterações | Compilou 100%? |
|---|---|---|---|---|---|---|---|---|
| ZS | 116 | 113 | 3 | 116 | 0 | 2/10 | 2 | Sim |
| FS | 79 | 78 | 1 | 79 | 0 | 1/10 | 1 | Sim |
| COT | 113 | 109 | 4 | 113 | 0 | 2/10 | 3 | Sim |
| **Total** | **308** | **300** | **8** | **308** | **0** | **5/30** | **6** | **Sim** |

> ZS gera mais testes por rodada (média 11,6 vs 7,9 FS vs 11,3 COT).  
> FS exige o menor número de reparos.  
> COT-08 (formatName) exigiu 2 iterações — o único caso de 2 iterações no nível unitário.  
> A função `formatName` foi a única que demandou reparo nas três estratégias (ZS-08, FS-08, COT-08) — reflexo da inconsistência intencional entre as duas implementações da função no projeto.

---

## 2. Testes de Widget (9 rodadas)

> Nível significativamente mais difícil: acoplamento estático Firebase impede mock efetivo.  
> Pass(1ª) e Pass(final) medem testes que executaram e passaram — não compilação.

| ID | Estratégia | Widget | Compilou(1ª) | Gerados | Pass(1ª) | Fail(1ª) | Pass(final) | Fail(final) | Iterações |
|---|---|---|---|---|---|---|---|---|---|
| WIDGET-ZS-01 | ZS | LoginScreen | Sim | 9 | 7 | 2 | 7 | 2 | 1 |
| WIDGET-ZS-02 | ZS | CriarPlaylistScreen | **Não** | 7 | 0 | 7 | 0 | 7 | 1 |
| WIDGET-ZS-03 | ZS | CadastroScreen | Sim | 11 | 4 | 7 | 10 | 1 | 2 |
| WIDGET-FS-01 | FS | LoginScreen | **Não** | 7 | 0 | 7 | 0 | 7 | 1 |
| WIDGET-FS-02 | FS | CriarPlaylistScreen | **Não** | 6 | 0 | 6 | 0 | 6 | 1 |
| WIDGET-FS-03 | FS | CadastroScreen | Sim | 8 | 0 | 8 | 6 | 2 | 1 |
| WIDGET-COT-01 | COT | LoginScreen | Sim | 14 | 0 | 14 | 0 | 14 | 2 |
| WIDGET-COT-02 | COT | CriarPlaylistScreen | **Não** | 9 | 0 | 9 | 0 | 9 | 2 |
| WIDGET-COT-03 | COT | CadastroScreen | Sim | 13 | 3 | 10 | 12 | 1 | 3 |

### Resumo WIDGET por estratégia

| Estratégia | Gerados | Pass(1ª) | Pass(final) | Fail(final) | Taxa final | Compilou(1ª) | Total iterações |
|---|---|---|---|---|---|---|---|
| ZS | 27 | 11 | 17 | 10 | 63% | 2/3 | 4 |
| FS | 21 | 0 | 6 | 15 | 29% | 1/3 | 3 |
| COT | 36 | 3 | 12 | 24 | 33% | 2/3 | 7 |
| **Total** | **84** | **14** | **35** | **49** | **42%** | **5/9** | **14** |

> COT gerou mais testes (36) mas teve taxa de aprovação final de 33% — os testes adicionais do COT dependiam de Firebase funcional.  
> ZS teve o melhor resultado final (63%) por abordar widgets de forma mais conservadora.  
> `CriarPlaylistScreen` falhou em todas as estratégias na compilação ou execução: dependência estática Firebase em initState impossibilita qualquer mock sem injeção de dependência.  
> `formatName` (ZS-08, FS-08, COT-08) e `CriarPlaylistScreen` (ZS-02, FS-02, COT-02) são os alvos com mais dificuldade sistemática.

---

## 3. Testes de Integração (9 rodadas)

> Fluxos multi-tela. Compilação variável por estratégia.  
> "Gerados (final)" = contagem final após todas as iterações (pode diferir da geração inicial).

| ID | Estratégia | Fluxo | Compilou(1ª) | Gerados(final) | Pass(1ª) | Fail(1ª) | Pass(final) | Fail(final) | Iterações |
|---|---|---|---|---|---|---|---|---|---|
| INT-ZS-01 | ZS | Login | **Não** | 5 | 0 | 5 | 3 | 2 | 2 |
| INT-ZS-02 | ZS | Cadastro | **Não** | 7 | 0 | 7 | 1 | 6 | 2 |
| INT-ZS-03 | ZS | Playlist | Sim | 8 | 0 | 5 | 8 | 0 | 2 |
| INT-FS-01 | FS | Login | Sim | 8 | 7 | 1 | 8 | 0 | 1 |
| INT-FS-02 | FS | Cadastro | Sim | 7 | 5 | 2 | 7 | 0 | 2 |
| INT-FS-03 | FS | Playlist | Sim | 8 | 8 | 0 | 8 | 0 | 0 |
| INT-COT-01 | COT | Login | Sim | 11 | 11 | 0 | 11 | 0 | 0 |
| INT-COT-02 | COT | Cadastro | Sim | 15 | 14 | 1 | 15 | 0 | 1 |
| INT-COT-03 | COT | Playlist | Sim | 11 | 11 | 0 | 11 | 0 | 0 |

### Resumo INT por estratégia

| Estratégia | Gerados | Pass(1ª) | Pass(final) | Fail(final) | Taxa final | Compilou(1ª) | Total iterações |
|---|---|---|---|---|---|---|---|
| ZS | 20 | 0 | 12 | 8 | 60% | 1/3 | 6 |
| FS | 23 | 20 | 23 | 0 | 100% | 3/3 | 3 |
| COT | 37 | 36 | 37 | 0 | 100% | 3/3 | 1 |
| **Total** | **80** | **56** | **72** | **8** | **90%** | **7/9** | **10** |

> ZS nunca compilou na 1ª tentativa nos fluxos com Firebase (Login e Cadastro) — alucinação de API do `firebase_auth_mocks`.  
> FS e COT compilaram em 100% dos casos e atingiram 100% de aprovação final.  
> COT gerou mais testes por rodada (média 12,3 vs 7,7 FS vs 6,7 ZS) e precisou de apenas 1 iteração total — o melhor custo-benefício no nível integration.  
> INT-COT-01 (Login) e INT-COT-03 (Playlist) passaram 100% na 1ª tentativa sem nenhum reparo.

---

## 4. Visão Geral — Todos os Níveis

| Nível | Estratégia | Gerados | Pass(final) | Fail(final) | Taxa final | Total iterações | Rodadas 0-reparo |
|---|---|---|---|---|---|---|---|
| UNIT | ZS | 116 | 116 | 0 | 100% | 2 | 8/10 |
| UNIT | FS | 79 | 79 | 0 | 100% | 1 | 9/10 |
| UNIT | COT | 113 | 113 | 0 | 100% | 3 | 8/10 |
| WIDGET | ZS | 27 | 17 | 10 | 63% | 4 | 0/3 |
| WIDGET | FS | 21 | 6 | 15 | 29% | 3 | 0/3 |
| WIDGET | COT | 36 | 12 | 24 | 33% | 7 | 0/3 |
| INT | ZS | 20 | 12 | 8 | 60% | 6 | 0/3 |
| INT | FS | 23 | 23 | 0 | 100% | 3 | 1/3 |
| INT | COT | 37 | 37 | 0 | 100% | 1 | 2/3 |

### Por estratégia (consolidado 48 rodadas)

| Estratégia | Total gerados | Total pass(final) | Total fail(final) | Taxa global | Total iterações | Média iter/rodada |
|---|---|---|---|---|---|---|
| ZS (16 rodadas) | 163 | 145 | 18 | 89% | 12 | 0,75 |
| FS (16 rodadas) | 123 | 108 | 15 | 88% | 7 | 0,44 |
| COT (16 rodadas) | 186 | 162 | 24 | 87% | 11 | 0,69 |
| **Total (48)** | **472** | **415** | **57** | **88%** | **30** | **0,63** |

> **Atenção:** as taxas globais são distorcidas pelo nível widget, onde todas as estratégias falharam significativamente. A análise por nível é mais informativa.

---

## 5. Achados Principais

### 5.1 Nível unitário — Sem diferença significativa
Todas as 3 estratégias atingiram 100% de aprovação final. A diferença está na **quantidade de testes gerados** (ZS e COT geram ~45% mais que FS) e na **taxa de aprovação na 1ª execução** (FS: 98,7%; ZS: 97,4%; COT: 96,5%). O custo de repair é mínimo em todos os casos (≤2 iterações).

### 5.2 Nível widget — Fracasso sistemático independente de estratégia
Nenhuma estratégia superou o limite arquitetural: `FirebaseAuth.instance` e `FirebaseFirestore.instance` estáticos impedem mock sem injeção de dependência. ZS foi marginalmente melhor (63% final) por ser mais conservador no escopo. COT gerou mais testes mas todos dependentes de Firebase — resultado paradoxal onde mais raciocínio levou a mais falhas.

### 5.3 Nível integration — COT e FS superiores, ZS problemático
ZS falhou na compilação em 2/3 casos por alucinação de API (parâmetros inexistentes em `firebase_auth_mocks 0.14.2`). FS e COT compilaram em 100% e aprovaram em 100% final. COT usou apenas 1 iteração de reparo total vs 4 do FS — demonstrando que o raciocínio explícito dos 5 passos identificou as restrições corretamente antes de escrever o código.

### 5.4 A função formatName como caso de estudo
`formatName` foi a única função que demandou repair nas 3 estratégias no nível unitário (ZS-08, FS-08, COT-08). Isso reflete a inconsistência intencional entre as duas implementações (`formatName` em `adicionar-musica.dart` preserva casing das letras internas; `capitalize` em `mapa.dart` lowercaseia) — o LLM gerou testes baseados em comportamento esperado pela convenção, não pelo comportamento real do código.

### 5.5 Transferência de padrões no FS
A estratégia FS demonstrou transferência efetiva de padrões do exemplo fornecido: o exemplo INT-ZS-03 (8/8 passando com dois pumps, sem Firebase) foi usado como referência para INT-FS-01, que replicou os mesmos padrões corretos na 1ª tentativa. O exemplo funcionou como "memória de padrões corretos".

---

## 6. Notas Metodológicas

- **"Testes gerados"** no nível integration refere-se à contagem final após reparos (a contagem pode variar durante o repair loop se o LLM adiciona ou remove testes).
- **"Compilou(1ª)"** = compilação sem nenhuma iteração de reparo.
- **Iterações** = número de rodadas de repair executadas (0 = geração inicial passou; máx. 3 por rodada).
- Widget tests: `CriarPlaylistScreen` (WIDGET-ZS-02, FS-02, COT-02) tem como causa raiz de falha a dependência Firebase em `initState` — não uma limitação da estratégia de prompt, mas uma limitação arquitetural da tela.
- O repair loop sempre contém apenas a saída de erro do terminal (sem dicas diagnósticas) para não viesar a comparação entre estratégias.
- **Desvio de modelo em WIDGET-COT-03:** Esta rodada foi executada com GPT-4o (2026-05-20) em vez de GPT-5.5 por indisponibilidade temporária do modelo. É o único desvio de protocolo nas 48 rodadas. Ver nota metodológica no doc `prompts/widget/cot/WIDGET-COT-03_cadastro.md`.
- **Alteração retroativa de `formatName`:** Durante a iteração de reparo de UNIT-COT-08, o LLM sugeriu corrigir a implementação da função `formatName` em `lib/utils/validators.dart` (substituição de `split(' ')` por `split(RegExp(r'\s+'))` com `trim()`). A correção foi aplicada e os arquivos de teste de UNIT-ZS-08 e UNIT-FS-08 foram retroativamente atualizados para refletir a nova implementação. Os docs de rodada dessas três rodadas registram o comportamento original; os arquivos em `test/unit/` refletem o comportamento pós-correção.
- **Versão do Flutter:** Os testes unitários e de widget foram executados com Flutter 3.41.7; os testes de integração com Flutter 3.41.6. A diferença de patch version não afeta a validade dos resultados (APIs de teste são estáveis entre patches da mesma minor version).
