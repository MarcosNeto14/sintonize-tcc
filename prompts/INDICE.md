# Índice das 48 Rodadas — Experimento TCC Sintonize

Tabela única de entrada rápida para todas as rodadas do experimento.  
Colunas: **ID** · **Nível** · **Estratégia** · **Alvo** · **Gerados** · **Pass(final)** · **Taxa final** · **Doc**

---

## Testes Unitários (30 rodadas)

| ID | Estratégia | Função | Gerados | Pass(final) | Taxa | Doc |
|---|---|---|---|---|---|---|
| UNIT-ZS-01 | ZS | validateNome | 12 | 12 | 100% | [doc](unit/zero-shot/UNIT-ZS-01_validateNome.md) |
| UNIT-ZS-02 | ZS | validateSenha | 7 | 7 | 100% | [doc](unit/zero-shot/UNIT-ZS-02_validateSenha.md) |
| UNIT-ZS-03 | ZS | validateNumero | 10 | 10 | 100% | [doc](unit/zero-shot/UNIT-ZS-03_validateNumero.md) |
| UNIT-ZS-04 | ZS | validateCEP | 10 | 10 | 100% | [doc](unit/zero-shot/UNIT-ZS-04_validateCEP.md) |
| UNIT-ZS-05 | ZS | validateEmail | 14 | 14 | 100% | [doc](unit/zero-shot/UNIT-ZS-05_validateEmail.md) |
| UNIT-ZS-06 | ZS | validateEmailLogin | 11 | 11 | 100% | [doc](unit/zero-shot/UNIT-ZS-06_validateEmailLogin.md) |
| UNIT-ZS-07 | ZS | validateEmailEdit | 13 | 13 | 100% | [doc](unit/zero-shot/UNIT-ZS-07_validateEmailEdit.md) |
| UNIT-ZS-08 | ZS | formatName ¹ | 10 | 10 | 100% | [doc](unit/zero-shot/UNIT-ZS-08_formatName.md) |
| UNIT-ZS-09 | ZS | capitalize | 10 | 10 | 100% | [doc](unit/zero-shot/UNIT-ZS-09_capitalize.md) |
| UNIT-ZS-10 | ZS | validateDate | 19 | 19 | 100% | [doc](unit/zero-shot/UNIT-ZS-10_validateDate.md) |
| UNIT-FS-01 | FS | validateNome | 6 | 6 | 100% | [doc](unit/few-shot/UNIT-FS-01_validateNome.md) |
| UNIT-FS-02 | FS | validateSenha | 5 | 5 | 100% | [doc](unit/few-shot/UNIT-FS-02_validateSenha.md) |
| UNIT-FS-03 | FS | validateNumero | 6 | 6 | 100% | [doc](unit/few-shot/UNIT-FS-03_validateNumero.md) |
| UNIT-FS-04 | FS | validateCEP | 7 | 7 | 100% | [doc](unit/few-shot/UNIT-FS-04_validateCEP.md) |
| UNIT-FS-05 | FS | validateEmail | 10 | 10 | 100% | [doc](unit/few-shot/UNIT-FS-05_validateEmail.md) |
| UNIT-FS-06 | FS | validateEmailLogin | 7 | 7 | 100% | [doc](unit/few-shot/UNIT-FS-06_validateEmailLogin.md) |
| UNIT-FS-07 | FS | validateEmailEdit | 10 | 10 | 100% | [doc](unit/few-shot/UNIT-FS-07_validateEmailEdit.md) |
| UNIT-FS-08 | FS | formatName ¹ | 7 | 7 | 100% | [doc](unit/few-shot/UNIT-FS-08_formatName.md) |
| UNIT-FS-09 | FS | capitalize | 8 | 8 | 100% | [doc](unit/few-shot/UNIT-FS-09_capitalize.md) |
| UNIT-FS-10 | FS | validateDate | 13 | 13 | 100% | [doc](unit/few-shot/UNIT-FS-10_validateDate.md) |
| UNIT-COT-01 | COT | validateNome | 10 | 10 | 100% | [doc](unit/cot/UNIT-COT-01_validateNome.md) |
| UNIT-COT-02 | COT | validateSenha | 9 | 9 | 100% | [doc](unit/cot/UNIT-COT-02_validateSenha.md) |
| UNIT-COT-03 | COT | validateNumero | 10 | 10 | 100% | [doc](unit/cot/UNIT-COT-03_validateNumero.md) |
| UNIT-COT-04 | COT | validateCEP | 11 | 11 | 100% | [doc](unit/cot/UNIT-COT-04_validateCEP.md) |
| UNIT-COT-05 | COT | validateEmail | 12 | 12 | 100% | [doc](unit/cot/UNIT-COT-05_validateEmail.md) |
| UNIT-COT-06 | COT | validateEmailLogin | 13 | 13 | 100% | [doc](unit/cot/UNIT-COT-06_validateEmailLogin.md) |
| UNIT-COT-07 | COT | validateEmailEdit | 11 | 11 | 100% | [doc](unit/cot/UNIT-COT-07_validateEmailEdit.md) |
| UNIT-COT-08 | COT | formatName ¹ | 12 | 12 | 100% | [doc](unit/cot/UNIT-COT-08_formatName.md) |
| UNIT-COT-09 | COT | capitalize | 10 | 10 | 100% | [doc](unit/cot/UNIT-COT-09_capitalize.md) |
| UNIT-COT-10 | COT | validateDate | 15 | 15 | 100% | [doc](unit/cot/UNIT-COT-10_validateDate.md) |

¹ `formatName` (ZS-08, FS-08, COT-08): única função que demandou repair nas 3 estratégias. COT-08 também modificou `lib/utils/validators.dart`, e os testes de ZS-08 e FS-08 foram retroativamente atualizados — ver notas metodológicas nos docs.

---

## Testes de Widget (9 rodadas)

| ID | Estratégia | Widget | Compilou | Gerados | Pass(final) | Taxa | Doc |
|---|---|---|---|---|---|---|---|
| WIDGET-ZS-01 | ZS | LoginScreen | Sim | 9 | 7 | 78% | [doc](widget/zero-shot/WIDGET-ZS-01_login.md) |
| WIDGET-ZS-02 | ZS | CriarPlaylistScreen | Não | 7 | 0 | 0% | [doc](widget/zero-shot/WIDGET-ZS-02_criarPlaylist.md) |
| WIDGET-ZS-03 | ZS | CadastroScreen | Sim | 11 | 10 | 91% | [doc](widget/zero-shot/WIDGET-ZS-03_cadastro.md) |
| WIDGET-FS-01 | FS | LoginScreen | Não | 7 | 0 | 0% | [doc](widget/few-shot/WIDGET-FS-01_login.md) |
| WIDGET-FS-02 | FS | CriarPlaylistScreen | Não | 6 | 0 | 0% | [doc](widget/few-shot/WIDGET-FS-02_criarPlaylist.md) |
| WIDGET-FS-03 | FS | CadastroScreen | Sim | 8 | 6 | 75% | [doc](widget/few-shot/WIDGET-FS-03_cadastro.md) |
| WIDGET-COT-01 | COT | LoginScreen | Sim | 14 | 0 | 0% | [doc](widget/cot/WIDGET-COT-01_login.md) |
| WIDGET-COT-02 | COT | CriarPlaylistScreen | Não | 9 | 0 | 0% | [doc](widget/cot/WIDGET-COT-02_criarPlaylist.md) |
| WIDGET-COT-03 | COT ² | CadastroScreen | Sim | 13 | 12 | 92% | [doc](widget/cot/WIDGET-COT-03_cadastro.md) |

² WIDGET-COT-03 foi executado com GPT-4o (desvio de protocolo — único caso entre 48 rodadas). Ver nota no doc.

Padrão dominante: `CriarPlaylistScreen` falhou em todas as estratégias (0% em todas) por dependência Firebase em `initState` impossível de mockar sem injeção de dependência. `CadastroScreen` teve os melhores resultados nas 3 estratégias.

---

## Testes de Integração (9 rodadas)

| ID | Estratégia | Fluxo | Compilou | Gerados | Pass(final) | Taxa | Doc |
|---|---|---|---|---|---|---|---|
| INT-ZS-01 | ZS | Login | Não | 5 | 3 | 60% | [doc](integration/zero-shot/INT-ZS-01_login.md) |
| INT-ZS-02 | ZS | Cadastro | Não | 7 | 1 | 14% | [doc](integration/zero-shot/INT-ZS-02_cadastro.md) |
| INT-ZS-03 | ZS | Playlist | Sim | 8 | 8 | 100% | [doc](integration/zero-shot/INT-ZS-03_playlist.md) |
| INT-FS-01 | FS | Login | Sim | 8 | 8 | 100% | [doc](integration/few-shot/INT-FS-01_login.md) |
| INT-FS-02 | FS | Cadastro | Sim | 7 | 7 | 100% | [doc](integration/few-shot/INT-FS-02_cadastro.md) |
| INT-FS-03 | FS | Playlist | Sim | 8 | 8 | 100% | [doc](integration/few-shot/INT-FS-03_playlist.md) |
| INT-COT-01 | COT | Login | Sim | 11 | 11 | 100% | [doc](integration/cot/INT-COT-01_login.md) |
| INT-COT-02 | COT | Cadastro | Sim | 15 | 15 | 100% | [doc](integration/cot/INT-COT-02_cadastro.md) |
| INT-COT-03 | COT | Playlist | Sim | 11 | 11 | 100% | [doc](integration/cot/INT-COT-03_playlist.md) |

ZS falhou na compilação em 2/3 rodadas (Login e Cadastro) por alucinação de API do `firebase_auth_mocks`. FS e COT atingiram 100% de aprovação final em todas as rodadas.

---

## Totais por nível

| Nível | Rodadas | Gerados | Pass(final) | Taxa |
|---|---|---|---|---|
| Unitário | 30 | 308 | 308 | 100% |
| Widget | 9 | 84 | 35 | 42% |
| Integração | 9 | 80 | 72 | 90% |
| **Global** | **48** | **472** | **415** | **88%** |

Para análise detalhada por estratégia e achados principais, ver `analise/dados_consolidados.md`.
