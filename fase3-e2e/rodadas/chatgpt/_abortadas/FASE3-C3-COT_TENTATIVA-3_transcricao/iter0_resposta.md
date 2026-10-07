<!-- Resposta do ChatGPT (sessão deslogada) à geração, rodada FASE3-C3-COT, TENTATIVA 3 (conversa nova,
     manual pelo autor), 2026-10-06, sem edição; colada pelo autor no chat do Claude Code.
     Só preâmbulo, sem código. Conversa: https://chatgpt.com/uc/6ac5a5be-b7cc-83ea-baff-9671d13c1ee0 -->

Vou estruturar os testes como E2E reais, sem mocks, usando os emuladores Firebase e a navegação da própria aplicação. Há um detalhe importante: como o CEP dispara uma chamada HTTP externa ao ViaCEP, o teste precisa tratar essa resposta como dependência real; além disso, o código fornecido não exibe um indicador de loading durante Auth/Firestore, então só podemos testar estados de espera observáveis pela conclusão da operação.
