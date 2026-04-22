# Protocolo Experimental — Geração de Testes com LLM

**Projeto:** Sintonize (Flutter + Firebase)
**Objetivo:** Avaliar a eficácia de três estratégias de engenharia de prompt (Zero-shot, Few-shot, Chain-of-Thought) na geração de testes automatizados para funções do projeto, usando ChatGPT como LLM.

---

## Estrutura de Pastas

```
sintonize/
├── lib/
│   └── utils/
│       └── validators.dart          ← funções-alvo extraídas do código original
├── prompts/                         ← documentação do experimento (ESTA PASTA)
│   ├── README.md                    ← este arquivo (índice + rastreabilidade)
│   ├── PROMPT_TEMPLATES.md          ← templates dos 3 prompts-base
│   ├── Template_Documentacao_Rodada.md  ← template de cada rodada
│   ├── unit/
│   │   ├── zero-shot/               ← 10 docs UNIT-ZS-NN_*.md
│   │   ├── few-shot/                ← 10 docs UNIT-FS-NN_*.md
│   │   └── cot/                     ← 10 docs UNIT-COT-NN_*.md
│   └── integration/                 ← (rodadas de integration test — TBD)
├── test/
│   └── unit/                        ← 30 arquivos .dart (um por rodada)
└── results/                         ← saídas do flutter test por rodada
    └── unit/
        ├── zero-shot/
        ├── few-shot/
        └── cot/
```

---

## Convenção de IDs

Formato: `NÍVEL-ESTRATÉGIA-NÚMERO`

**Nível da pirâmide:**
| Código | Significado |
|---|---|
| UNIT | Teste unitário |
| WIDGET | Widget test |
| INT | Integration test |

**Estratégia de prompt:**
| Código | Nome completo |
|---|---|
| ZS | Zero-shot |
| FS | Few-shot |
| COT | Chain-of-Thought |
| MS | Multi-step (reservado para integration) |
| CE | Context enrichment (reservado para integration) |

**Número:** 01–10, seguindo a ordem fixa das funções (ver tabela de rastreabilidade abaixo).

**Exemplos:**
- `UNIT-ZS-01` → unitário, zero-shot, função `validateNome`
- `UNIT-FS-05` → unitário, few-shot, função `validateEmail`
- `UNIT-COT-10` → unitário, chain-of-thought, função `validateDate`

---

## Tabela de Rastreabilidade — Nível Unitário

Cada linha representa **uma função × três estratégias = três rodadas**. Total: **30 rodadas**.

| # | Função | Arquivo de origem (lib/) | Doc Zero-shot | Doc Few-shot | Doc CoT | Arquivo de teste (test/unit/) | Resultado (results/) |
|---|---|---|---|---|---|---|---|
| 01 | `validateNome` | `cadastro.dart` (validator inline do campo Nome) | [UNIT-ZS-01](unit/zero-shot/UNIT-ZS-01_validateNome.md) | [UNIT-FS-01](unit/few-shot/UNIT-FS-01_validateNome.md) | [UNIT-COT-01](unit/cot/UNIT-COT-01_validateNome.md) | `validate_nome_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 02 | `validateSenha` | `login.dart` (validator inline do TextFormField de senha) | [UNIT-ZS-02](unit/zero-shot/UNIT-ZS-02_validateSenha.md) | [UNIT-FS-02](unit/few-shot/UNIT-FS-02_validateSenha.md) | [UNIT-COT-02](unit/cot/UNIT-COT-02_validateSenha.md) | `validate_senha_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 03 | `validateNumero` | `cadastro.dart` (`_validateNumero`) | [UNIT-ZS-03](unit/zero-shot/UNIT-ZS-03_validateNumero.md) | [UNIT-FS-03](unit/few-shot/UNIT-FS-03_validateNumero.md) | [UNIT-COT-03](unit/cot/UNIT-COT-03_validateNumero.md) | `validate_numero_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 04 | `validateCEP` | `cadastro.dart` (`_validateCEP`) | [UNIT-ZS-04](unit/zero-shot/UNIT-ZS-04_validateCEP.md) | [UNIT-FS-04](unit/few-shot/UNIT-FS-04_validateCEP.md) | [UNIT-COT-04](unit/cot/UNIT-COT-04_validateCEP.md) | `validate_cep_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 05 | `validateEmail` | `cadastro.dart` (`_validateEmail`) | [UNIT-ZS-05](unit/zero-shot/UNIT-ZS-05_validateEmail.md) | [UNIT-FS-05](unit/few-shot/UNIT-FS-05_validateEmail.md) | [UNIT-COT-05](unit/cot/UNIT-COT-05_validateEmail.md) | `validate_email_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 06 | `validateEmailLogin` | `login.dart` (validator inline do TextFormField de email) | [UNIT-ZS-06](unit/zero-shot/UNIT-ZS-06_validateEmailLogin.md) | [UNIT-FS-06](unit/few-shot/UNIT-FS-06_validateEmailLogin.md) | [UNIT-COT-06](unit/cot/UNIT-COT-06_validateEmailLogin.md) | `validate_email_login_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 07 | `validateEmailEdit` | `alterar-dados.dart` (`_validateEmail`) | [UNIT-ZS-07](unit/zero-shot/UNIT-ZS-07_validateEmailEdit.md) | [UNIT-FS-07](unit/few-shot/UNIT-FS-07_validateEmailEdit.md) | [UNIT-COT-07](unit/cot/UNIT-COT-07_validateEmailEdit.md) | `validate_email_edit_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 08 | `formatName` | `adicionar-musica.dart` + 5 outros arquivos (`_formatName`) | [UNIT-ZS-08](unit/zero-shot/UNIT-ZS-08_formatName.md) | [UNIT-FS-08](unit/few-shot/UNIT-FS-08_formatName.md) | [UNIT-COT-08](unit/cot/UNIT-COT-08_formatName.md) | `format_name_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 09 | `capitalize` | `mapa.dart` (`_capitalize`) | [UNIT-ZS-09](unit/zero-shot/UNIT-ZS-09_capitalize.md) | [UNIT-FS-09](unit/few-shot/UNIT-FS-09_capitalize.md) | [UNIT-COT-09](unit/cot/UNIT-COT-09_capitalize.md) | `capitalize_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |
| 10 | `validateDate` | `cadastro.dart` (`_validateDate`) | [UNIT-ZS-10](unit/zero-shot/UNIT-ZS-10_validateDate.md) | [UNIT-FS-10](unit/few-shot/UNIT-FS-10_validateDate.md) | [UNIT-COT-10](unit/cot/UNIT-COT-10_validateDate.md) | `validate_date_{zs,fs,cot}_test.dart` | `results/unit/{estratégia}/` |

**Nota sobre idiomas nos nomes:** `validateNome`, `validateSenha`, `validateNumero`, `validateCEP` estão em português; `formatName`, `capitalize`, `validateDate` em inglês. Essa mistura é **herdada do código-fonte original** do projeto Sintonize e foi preservada intencionalmente para manter fidelidade com o artefato sob teste.

**Nota sobre `formatName`:** a função aparece duplicada em 6 arquivos do projeto original (`adicionar-musica.dart`, entre outros). Foi consolidada em `lib/utils/validators.dart` como parte da refatoração preparatória ao experimento.

---

## Workflow de cada Rodada

1. **Abrir o arquivo de doc correspondente** (ex: `unit/zero-shot/UNIT-ZS-01_validateNome.md`).
2. **Copiar o prompt-base** da estratégia em `PROMPT_TEMPLATES.md` e substituir o marcador pelo código da função de `lib/utils/validators.dart`.
3. **Abrir uma conversa nova no ChatGPT** e colar o prompt.
4. **Colar o código gerado** no arquivo de teste correspondente em `test/unit/` (substituindo o placeholder).
5. **Rodar** `flutter test test/unit/{arquivo}_test.dart` e **salvar a saída** em `results/unit/{estratégia}/`.
6. **Preencher o arquivo de doc** com: prompt exato, resposta completa, métricas, e iterações de reparo (se houver).
7. Se houve falha: usar o **prompt de reparo** de `PROMPT_TEMPLATES.md` (máximo 3 iterações por rodada).

---

## Métricas Coletadas por Rodada

| Categoria | Métricas |
|---|---|
| **Execução** | Compilou? / Testes gerados / Passaram / Falharam / Ajuste manual de import? |
| **Reparo** | Nº de iterações até passar (0 a 3) |
| **Qualitativa** | Alucinações / Omissões / Redundâncias / Qualidade dos nomes / Cobertura de casos de borda |
| **Contexto** | Versão do modelo / Data e hora / Versão do Flutter |

---

## Totais do Experimento

| Nível | Funções | Estratégias | Rodadas |
|---|---|---|---|
| Unitário | 10 | 3 (ZS, FS, CoT) | **30** |
| Integration | TBD | TBD | TBD |
| Widget | TBD | TBD | TBD |

---

## Referências Internas

- [`PROMPT_TEMPLATES.md`](PROMPT_TEMPLATES.md) — prompts-base das 3 estratégias + prompt de reparo.
- [`Template_Documentacao_Rodada.md`](Template_Documentacao_Rodada.md) — template canônico de uma rodada (reproduzido em cada arquivo UNIT-*-NN).
