# Sintonize — TCC

**Aluno:** Marcos Leite Bezerra Neto
**Curso:** Bacharelado em Sistemas de Informação — UFRPE
**Orientador:** Prof. Cleyton Magalhães

## Sobre

Repositório do experimento do TCC "Uso de Modelos de Linguagem de Grande Escala na Implementação da Pirâmide de Testes: Um Estudo de Caso em uma Aplicação Móvel".

Este repositório contém o código-fonte do app Sintonize (Flutter + Firebase) com as adaptações necessárias para o experimento, os testes gerados por LLM, a documentação de cada rodada experimental e os resultados da análise.

## Estrutura do repositório

- `lib/` — código-fonte do Sintonize (clone do projeto original com refatoração mínima)
- `lib/utils/validators.dart` — classe `Validators` extraída para viabilizar testes unitários
- `test/unit/` — testes unitários gerados pelo ChatGPT (10 funções × 3 estratégias = 30 arquivos)
- `integration_test/` — testes de integração gerados pelo ChatGPT
- `prompts/` — documentação completa de cada rodada (prompt, resposta, resultado, análise)
- `e2e-manual/` — documentação dos fluxos E2E executados manualmente
- `results/` — consolidação de métricas e análise comparativa

## Como reproduzir

1. Instalar Flutter (SDK Dart `>=2.17.0 <4.0.0`, conforme `pubspec.yaml`)
2. Clonar este repositório
3. Rodar `flutter pub get`
4. Rodar `flutter test test/unit/` para executar os testes unitários

## Metodologia

Os testes foram gerados utilizando o ChatGPT (GPT-4) com três estratégias de engenharia de prompt:

- **Zero-shot (ZS):** prompt simples com o código da função
- **Few-shot (FS):** prompt com exemplos de testes antes da função-alvo
- **Chain-of-Thought (COT):** prompt instruindo raciocínio passo a passo

Cada rodada foi documentada com metadados completos (data, versão do modelo, prompt exato) para garantir transparência e reprodutibilidade.
