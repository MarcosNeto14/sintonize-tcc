# E2E-01 — Cadastro Completo

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-01 |
| **Fluxo** | Cadastro completo (novo usuário) |
| **Telas envolvidas** | LoginScreen → CadastroScreen → GenerosCadastroScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | [preencher] |
| **Dispositivo/Emulador** | [preencher — ex: Pixel 7 emulator, Android 14] |
| **Versão do app** | Flutter 3.41.6 |

---

## Pré-condições

- App instalado e executando no dispositivo/emulador
- Conexão com internet ativa (Firebase)
- Usuário **não** possui conta cadastrada com o e-mail a ser usado

---

## Passos e Resultados

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| 1 | Abrir o app | Tela de Login é exibida com campos E-mail, Senha, botão "Entrar", links "Esqueci minha senha" e "Não tem cadastro? Cadastre-se!" | [preencher] | ⬜ |
| 2 | Tocar em "Não tem cadastro? Cadastre-se!" | Tela de Cadastro é exibida com campos: Nome, Data de Nascimento, E-mail, Senha, Confirmar Senha, CEP, Cidade, Estado, Número, Complemento | [preencher] | ⬜ |
| 3 | Preencher Nome com valor válido (ex: "João Silva") | Campo aceita o texto | [preencher] | ⬜ |
| 4 | Preencher Data de Nascimento com formato válido (ex: "01/01/2000") | Campo aceita o texto | [preencher] | ⬜ |
| 5 | Preencher E-mail com endereço válido e único | Campo aceita o texto | [preencher] | ⬜ |
| 6 | Preencher Senha com mínimo 6 caracteres | Campo aceita o texto (oculto) | [preencher] | ⬜ |
| 7 | Preencher Confirmar Senha com o mesmo valor | Campo aceita o texto (oculto) | [preencher] | ⬜ |
| 8 | Preencher CEP válido (ex: "01310-100") | Campo aceita o texto; cidade/estado podem ser preenchidos automaticamente via ViaCEP | [preencher] | ⬜ |
| 9 | Preencher Número (ex: "100") | Campo aceita o texto | [preencher] | ⬜ |
| 10 | Rolar até o botão "Cadastrar" e tocar | App exibe indicador de carregamento; após sucesso, navega para GenerosCadastroScreen | [preencher] | ⬜ |
| 11 | Na GenerosCadastroScreen, visualizar lista de gêneros | Lista com gêneros musicais (Rock, Pop, Jazz, etc.) exibida com switches | [preencher] | ⬜ |
| 12 | Ativar ao menos 1 gênero musical | Switch muda para ligado | [preencher] | ⬜ |
| 13 | Tocar em "Confirmar" | App navega para TelaInicialScreen | [preencher] | ⬜ |
| 14 | Verificar que TelaInicialScreen é exibida corretamente | Conteúdo da tela inicial visível; usuário autenticado | [preencher] | ⬜ |

---

## Cenários de Erro (validações)

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Cadastrar" com Nome contendo números (ex: "João123") | Mensagem "O nome não pode conter números ou caracteres especiais" | [preencher] | ⬜ |
| E2 | Tocar "Cadastrar" com E-mail inválido (ex: "teste") | Mensagem "E-mail inválido" | [preencher] | ⬜ |
| E3 | Tocar "Cadastrar" com Senha < 6 caracteres | Mensagem "A senha deve ter pelo menos 6 caracteres" | [preencher] | ⬜ |
| E4 | Tocar "Cadastrar" com senhas diferentes | Mensagem "As senhas não coincidem" | [preencher] | ⬜ |
| E5 | Tocar "Cadastrar" com CEP inválido (ex: "123") | Mensagem "CEP inválido. Formato correto: XXXXX-XXX" | [preencher] | ⬜ |
| E6 | Tocar "Confirmar" na GenerosCadastroScreen sem selecionar gênero | SnackBar "Selecione pelo menos um gênero musical!" | [preencher] | ⬜ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | [preencher] / 14 |
| **Passos aprovados** | [preencher] |
| **Passos reprovados** | [preencher] |
| **Erros validados** | [preencher] / 6 |
| **Status geral** | ⬜ Aprovado / ⬜ Reprovado / ⬜ Aprovado com ressalvas |

---

## Observações

[preencher — comportamentos inesperados, bugs observados, notas]
