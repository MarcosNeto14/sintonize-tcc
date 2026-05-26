# E2E Manual — Sintonize

Testes end-to-end executados manualmente no dispositivo/emulador.  
Nível mais alto da pirâmide de testes — sem geração por LLM.

## Roteiros

| ID | Fluxo | Passos | Status |
|---|---|---|---|
| [E2E-01](E2E-01_cadastro_completo.md) | Cadastro completo (novo usuário) | 14 + 6 erros | ✅ Aprovado |
| [E2E-02](E2E-02_login_completo.md) | Login de usuário existente | 5 + 4 erros | ✅ Aprovado |
| [E2E-03](E2E-03_criar_playlist.md) | Criar playlist com músicas | 8 + 1 erro | ✅ Aprovado |
| [E2E-04](E2E-04_adicionar_musica.md) | Adicionar música a playlist existente | 7 + 1 erro | ✅ Aprovado |

**Total:** 34 passos + 12 cenários de erro

## Como executar

1. Instalar o app no dispositivo/emulador (`flutter run`)
2. Seguir os passos de cada roteiro na ordem recomendada: E2E-01 → E2E-02 → E2E-03 → E2E-04
3. Preencher "Resultado Real" e marcar Status (✅ aprovado / ❌ reprovado)
4. Preencher "Resultado Geral" ao final de cada roteiro
5. Atualizar a tabela acima com o status final

## Ordem recomendada de execução

E2E-01 cria o usuário que será usado nos demais roteiros.  
E2E-03 cria a playlist usada no E2E-04.  
Execute na sequência para reutilizar o estado do Firebase.
