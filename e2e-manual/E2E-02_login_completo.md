# E2E-02 — Login Completo

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-02 |
| **Fluxo** | Login de usuário existente |
| **Telas envolvidas** | LoginScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | 2026-05-25 |
| **Dispositivo/Emulador** | Web — Google Chrome (`flutter run -d chrome`) |
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
| 1 | Abrir o app | Tela de Login exibida | Conforme esperado | ✅ |
| 2 | Preencher E-mail com credencial válida | Campo aceita o texto | Conforme esperado | ✅ |
| 3 | Preencher Senha correta | Campo aceita o texto (oculto) | Conforme esperado | ✅ |
| 4 | Tocar em "Entrar" | App autentica via Firebase e navega para TelaInicialScreen | Conforme esperado | ✅ |
| 5 | Verificar que TelaInicialScreen é exibida | Conteúdo da tela inicial visível | Conforme esperado | ✅ |

---

## Cenários de Erro (validações)

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Entrar" com campos vazios | Mensagem "Por favor, insira seu e-mail" | Conforme esperado | ✅ |
| E2 | Tocar "Entrar" com e-mail inválido | Mensagem "Por favor, insira um e-mail válido" | Conforme esperado | ✅ |
| E3 | Tocar "Entrar" com senha < 6 caracteres | Mensagem "A senha deve ter pelo menos 6 caracteres" | Conforme esperado | ✅ |
| E4 | Tocar "Entrar" com credenciais erradas (e-mail válido, senha incorreta) | SnackBar com mensagem de erro do Firebase | Conforme esperado | ✅ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | 5 / 5 |
| **Passos aprovados** | 5 |
| **Passos reprovados** | 0 |
| **Erros validados** | 4 / 4 |
| **Status geral** | ✅ Aprovado |

---

## Observações

Nenhuma. Todos os 5 passos e 4 cenários de erro executados sem desvios.
