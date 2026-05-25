# E2E-02 — Login Completo

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-02 |
| **Fluxo** | Login de usuário existente |
| **Telas envolvidas** | LoginScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | [preencher] |
| **Dispositivo/Emulador** | [preencher] |
| **Versão do app** | Flutter 3.41.6 |

---

## Pré-condições

- App instalado e executando
- Conexão com internet ativa (Firebase)
- Usuário já possui conta cadastrada (pode usar a conta criada no E2E-01)

---

## Passos e Resultados

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| 1 | Abrir o app | Tela de Login exibida | [preencher] | ⬜ |
| 2 | Preencher E-mail com credencial válida | Campo aceita o texto | [preencher] | ⬜ |
| 3 | Preencher Senha correta | Campo aceita o texto (oculto) | [preencher] | ⬜ |
| 4 | Tocar em "Entrar" | App autentica via Firebase e navega para TelaInicialScreen | [preencher] | ⬜ |
| 5 | Verificar que TelaInicialScreen é exibida | Conteúdo da tela inicial visível | [preencher] | ⬜ |

---

## Cenários de Erro (validações)

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Entrar" com campos vazios | Mensagem "Por favor, insira seu e-mail" | [preencher] | ⬜ |
| E2 | Tocar "Entrar" com e-mail inválido | Mensagem "Por favor, insira um e-mail válido" | [preencher] | ⬜ |
| E3 | Tocar "Entrar" com senha < 6 caracteres | Mensagem "A senha deve ter pelo menos 6 caracteres" | [preencher] | ⬜ |
| E4 | Tocar "Entrar" com credenciais erradas (e-mail válido, senha incorreta) | SnackBar com mensagem de erro do Firebase | [preencher] | ⬜ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | [preencher] / 5 |
| **Passos aprovados** | [preencher] |
| **Passos reprovados** | [preencher] |
| **Erros validados** | [preencher] / 4 |
| **Status geral** | ⬜ Aprovado / ⬜ Reprovado / ⬜ Aprovado com ressalvas |

---

## Observações

[preencher]
