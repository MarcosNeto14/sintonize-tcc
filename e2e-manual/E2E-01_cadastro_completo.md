# E2E-01 — Cadastro Completo

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-01 |
| **Fluxo** | Cadastro completo (novo usuário) |
| **Telas envolvidas** | LoginScreen → CadastroScreen → GenerosCadastroScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | 2026-05-25 |
| **Dispositivo/Emulador** | Web — Google Chrome (`flutter run -d chrome`) |
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
| 1 | Abrir o app | Tela inicial é exibida com botão "Entrar" e "Cadastro" | Conforme esperado | ✅ |
| 2 | Tocar em "Cadastro" | Tela de Cadastro é exibida com campos: Nome, Data de Nascimento, E-mail, Senha, Confirmar Senha, CEP, Cidade, Estado, Número, Complemento | Conforme esperado | ✅ |
| 3 | Preencher Nome com valor válido (ex: "João Silva") | Campo aceita o texto | Conforme esperado | ✅ |
| 4 | Preencher Data de Nascimento com formato válido (ex: "01/01/2000") | Campo aceita o texto | Conforme esperado | ✅ |
| 5 | Preencher E-mail com endereço válido e único | Campo aceita o texto | Conforme esperado | ✅ |
| 6 | Preencher Senha com mínimo 6 caracteres | Campo aceita o texto (oculto) | Conforme esperado | ✅ |
| 7 | Preencher Confirmar Senha com o mesmo valor | Campo aceita o texto (oculto) | Conforme esperado | ✅ |
| 8 | Preencher CEP válido (ex: "01310-100") | Campo aceita o texto; cidade/estado podem ser preenchidos automaticamente via ViaCEP | Conforme esperado | ✅ |
| 9 | Preencher Número (ex: "100") | Campo aceita o texto | Conforme esperado | ✅ |
| 10 | Rolar até o botão "Cadastrar" e tocar | App exibe indicador de carregamento; após sucesso, navega para GenerosCadastroScreen | Conforme esperado | ✅ |
| 11 | Na GenerosCadastroScreen, visualizar lista de gêneros | Lista com gêneros musicais (Rock, Pop, Jazz, etc.) exibida com switches | Conforme esperado | ✅ |
| 12 | Ativar ao menos 1 gênero musical | Switch muda para ligado | Conforme esperado | ✅ |
| 13 | Tocar em "Confirmar" | App navega para TelaInicialScreen | Conforme esperado | ✅ |
| 14 | Verificar que TelaInicialScreen é exibida corretamente | Conteúdo da tela inicial visível; usuário autenticado | Conforme esperado | ✅ |

---

## Cenários de Erro (validações)

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Cadastrar" com Nome contendo números (ex: "João123") | Mensagem "O nome não pode conter números ou caracteres especiais" | Conforme esperado | ✅ |
| E2 | Tocar "Cadastrar" com E-mail inválido (ex: "teste") | Mensagem "E-mail inválido" | Conforme esperado | ✅ |
| E3 | Tocar "Cadastrar" com Senha < 6 caracteres | Mensagem "A senha deve ter pelo menos 6 caracteres" | Conforme esperado | ✅ |
| E4 | Tocar "Cadastrar" com senhas diferentes | Mensagem "As senhas não coincidem" | Conforme esperado | ✅ |
| E5 | Tocar "Cadastrar" com CEP inválido (ex: "123") | Mensagem "CEP inválido. Formato correto: XXXXX-XXX" | Conforme esperado | ✅ |
| E6 | Tocar "Confirmar" na GenerosCadastroScreen sem selecionar gênero | SnackBar "Selecione pelo menos um gênero musical!" | Conforme esperado | ✅ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | 14 / 14 |
| **Passos aprovados** | 14 |
| **Passos reprovados** | 0 |
| **Erros validados** | 6 / 6 |
| **Status geral** | ✅ Aprovado |

---

## Observações

Nenhuma. Todos os 14 passos e 6 cenários de erro executados sem desvios.
