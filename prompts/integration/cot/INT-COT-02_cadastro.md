# INT-COT-02 — Fluxo Cadastro — Chain-of-Thought

## Metadados

| Campo                    | Valor                                                          |
| ------------------------ | -------------------------------------------------------------- |
| **ID da Rodada**         | INT-COT-02                                                     |
| **Fluxo testado**        | Cadastro (CadastroScreen → GenerosCadastroScreen)              |
| **Arquivos envolvidos**  | lib/cadastro.dart, lib/generos-cadastro.dart                  |
| **Nível da pirâmide**    | Integration test                                               |
| **Estratégia de prompt** | Chain-of-Thought                                               |
| **LLM utilizado**        | ChatGPT                                                        |
| **Versão do modelo**     | [preencher]                                                    |
| **Data de acesso**       | 2026-05-25                                                     |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                            |
| **Framework de teste**   | flutter_test                                                   |
| **Versão do Flutter**    | Flutter 3.41.6 • Dart 3.11.4                                  |

---

## Prompt Enviado

```
Quero que você gere um teste de integração em Dart para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:

1. Analise o fluxo [...]
2. Identifique as dependências [...]
3. Monte a estrutura de navegação [...]
4. Identifique os cenários de teste [...]
5. Escreva os testes [...]

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

Fluxo a testar: CadastroScreen → GenerosCadastroScreen (submit bem-sucedido via Firebase) + link "Já tem uma conta? Faça login" → LoginScreen.

Restrições: FirebaseAuth.instance e FirebaseFirestore.instance estáticos; não testar submit válido; formulário em SingleChildScrollView requer ensureVisible; GenerosCadastroScreen pode ser testada isoladamente (initState sem Firebase); usar scrollUntilVisible para ListView lazy; nunca usar pumpAndSettle.

[código completo de lib/cadastro.dart e lib/generos-cadastro.dart]

Dependências disponíveis: firebase_auth_mocks, fake_cloud_firestore, mockito.
```

---

## Resposta do LLM — Análise CoT

### 1. Análise do fluxo

O fluxo começa na CadastroScreen com formulário completo (nome, data, email, senha, endereço). Ao tocar em "Cadastrar", validações locais são executadas; se tudo válido, chama FirebaseAuth + Firestore e navega para GenerosCadastroScreen. Pontos de decisão: validação local, sucesso/falha Firebase Auth, sucesso/falha Firestore, seleção obrigatória de gênero.

### 2. Dependências e estratégia

| Tela | Dependência | Estratégia |
|---|---|---|
| CadastroScreen | FirebaseAuth (estático) | Não testar submit válido |
| CadastroScreen | Firestore (estático) | Não testar submit válido |
| CadastroScreen | HTTP ViaCEP | Não testar lookup de CEP |
| GenerosCadastroScreen | FirebaseAuth.currentUser | Não testar _salvarGeneros() |
| GenerosCadastroScreen | Lista local no initState | Pode ser testada isoladamente |

### 3. Estrutura de navegação

`MaterialApp(home: child)` simples. Rotas não nomeadas (as telas usam `MaterialPageRoute` direto). Para navegação, padrão de dois pumps após tap.

### 4. Cenários identificados (15 testes)

- CadastroScreen: renderização, navegação para LoginScreen, 7 validações (nome inválido, data inválida, email inválido, senha curta, senhas diferentes, CEP inválido, número não numérico), 2 testes de ensureVisible
- GenerosCadastroScreen: renderização parcial, scrollUntilVisible para item lazy, seleção de gênero, snackbar sem seleção

---

## Resultado da Execução (Geração inicial)

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 15    |
| **Testes passaram** | 14    |
| **Testes falharam** | 1     |

### Saída do terminal

```
00:00 +1: CadastroScreen renderiza elementos principais da tela
00:02 +1 -1: CadastroScreen navega para LoginScreen ao tocar no link [E]
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "LoginScreen": []>
  (linha 46)
00:11 +14 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** Teste de navegação usou apenas `pump(Duration(milliseconds: 500))` — um único pump insuficiente para concluir a transição de rota do `Navigator.push`.

- **Prompt de correção enviado:**
```
O teste de integração falhou com o seguinte erro:

00:02 +1 -1: CadastroScreen navega para LoginScreen ao tocar no link [E]
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "LoginScreen": []>

00:11 +14 -1: Some tests failed.

Corrija o teste para que compile e passe corretamente. Não modifique o código das telas, apenas o código do teste.
```

- **Resposta do LLM:** Adicionou segundo `pump()` sem duração após `pump(Duration(milliseconds: 500))` para processar o frame pendente do `Navigator.push()`. Explicou corretamente que o primeiro pump avança a animação e o segundo finaliza o frame do Navigator.

- **Resultado após correção:** 15/15 — todos os testes passaram.

### Saída final do terminal

```
00:00 +0: CadastroScreen renderiza elementos principais da tela
00:01 +1: CadastroScreen navega para LoginScreen ao tocar no link
00:01 +2: CadastroScreen exibe erro para nome inválido
00:02 +3: CadastroScreen exibe erro para data inválida
00:02 +4: CadastroScreen exibe erro para email inválido
00:03 +5: CadastroScreen exibe erro para senha curta
00:03 +6: CadastroScreen exibe erro para senhas diferentes
00:03 +7: CadastroScreen exibe erro para CEP inválido
00:04 +8: CadastroScreen exibe erro para número não numérico
00:04 +9: CadastroScreen botão cadastrar exige ensureVisible
00:04 +10: CadastroScreen link login exige ensureVisible
00:04 +11: GenerosCadastroScreen renderiza lista de gêneros
00:04 +12: GenerosCadastroScreen scrollUntilVisible encontra item lazy do ListView
00:05 +13: GenerosCadastroScreen seleciona gênero musical
00:05 +14: GenerosCadastroScreen exibe snackbar ao confirmar sem selecionar gênero
00:05 +15: All tests passed!
```

## Resultado Final

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 15    |
| **Testes passaram** | 15    |
| **Testes falharam** | 0     |
| **Iterações**       | 1     |
