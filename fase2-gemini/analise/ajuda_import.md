# Ajuda de import nos 18 prompts de bug plantado da Fase 2 (ChatGPT e Gemini)

Levantamento de 2026-10-08 sobre `fase2/prompts_prontos/FASE2-{U,W,I}{CRASH,SILENT}-{ZS,FS,COT}.md`.
Os 18 arquivos de `fase2-gemini/prompts_prontos/` são byte-idênticos (conferido com `cmp`), logo
o que vale para um modelo vale para o outro. Só conta o **corpo enviado ao modelo** (o trecho
entre o 2º e o 3º `---`); a linha `**Alvo:**`/`**Arquivo:**` do cabeçalho fica fora e não foi contada.

## Por prompt

| Prompt | Linha(s) no corpo | Evidência | Tipo |
|---|---|---|---|
| U-CRASH-ZS | 27 | "A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart …" | caminho em prosa |
| U-CRASH-FS | 65 | "A função faz parte da classe Validators em lib/utils/validators.dart …" | caminho em prosa |
| U-CRASH-COT | 36–37 | idem + "Use `import 'package:sintonize/utils/validators.dart';` nos testes." | **import explícito** |
| U-SILENT-ZS | 29 | "… no arquivo lib/utils/validators.dart …" | caminho em prosa |
| U-SILENT-FS | 67 | "… em lib/utils/validators.dart …" | caminho em prosa |
| U-SILENT-COT | 38–39 | idem + "Use `import 'package:sintonize/utils/validators.dart';` nos testes." | **import explícito** |
| W-CRASH-ZS | 255 | "- Use `import 'package:sintonize/criar_playlist.dart';` para importar o widget" | **import explícito** |
| W-CRASH-FS | — | nenhum caminho do projeto (só `import 'package:flutter_test/flutter_test.dart';` no exemplo) | **nenhum** |
| W-CRASH-COT | 209 | "Use `import 'package:sintonize/criar_playlist.dart';` para os imports." | **import explícito** |
| W-SILENT-ZS | 223 | "- Use `import 'package:sintonize/login.dart';` para importar o widget" | **import explícito** |
| W-SILENT-FS | — | nenhum caminho do projeto | **nenhum** |
| W-SILENT-COT | 195 | "Use `import 'package:sintonize/login.dart';` para os imports." | **import explícito** |
| I-CRASH-ZS | 291 | "- Use `import 'package:sintonize/cadastro.dart';` e `import 'package:sintonize/generos-cadastro.dart';`" | **import explícito** |
| I-CRASH-FS | 77, 142 | só os cabeçalhos `// ─── lib/cadastro.dart ───` e `// ─── lib/generos-cadastro.dart ───` dentro do bloco de código | caminho em comentário de código |
| I-CRASH-COT | 36, 92, 152 | cabeçalhos idem + "Use `import 'package:sintonize/...'` para os imports do projeto." (sem nome de arquivo) | import **genérico** |
| I-SILENT-ZS | 197 | "- Use `import 'package:sintonize/criar_playlist.dart';`" | **import explícito** |
| I-SILENT-FS | — | nenhum caminho do projeto | **nenhum** |
| I-SILENT-COT | 193 | "Use `import 'package:sintonize/criar_playlist.dart';` para os imports do projeto." | **import explícito** |

## Contagens, por definição

| Definição | Prompts | Quantos |
|---|---|---|
| Linha `import 'package:sintonize/<arquivo>.dart'` com nome de arquivo | U-CRASH-COT, U-SILENT-COT, W-CRASH-ZS, W-CRASH-COT, W-SILENT-ZS, W-SILENT-COT, I-CRASH-ZS, I-SILENT-ZS, I-SILENT-COT | **9** |
| + linha de import genérica (`package:sintonize/...`) | + I-CRASH-COT | **10** |
| + caminho do arquivo em prosa ou em comentário de código (sem linha de import) | + U-CRASH-ZS, U-CRASH-FS, U-SILENT-ZS, U-SILENT-FS, I-CRASH-FS | **15** |
| Nenhuma informação de caminho | W-CRASH-FS, W-SILENT-FS, I-SILENT-FS | 3 |

Só a linha de `criar_playlist.dart` (a ajuda introduzida por causa do 0 % de `CriarPlaylistScreen`
na Fase 1, descrita em `fase2-gemini/README.md`, "Caminho de import"): W-CRASH-ZS, W-CRASH-COT,
I-SILENT-ZS, I-SILENT-COT = **4**.

## Qual contagem é a certa

- **"4"** é a contagem restrita à linha de `criar_playlist.dart` nos prompts de bug, como está no
  README da réplica ("Os prompts de W-CRASH-{ZS,COT} e I-SILENT-{ZS,COT} do piloto também a
  trazem"). Está certa para essa definição, mas **não** é "quantos prompts de bug receberam o
  caminho": deixa de fora W-SILENT-ZS/COT (`login.dart`), U-CRASH-COT/U-SILENT-COT
  (`validators.dart`) e I-CRASH-ZS (`cadastro.dart` + `generos-cadastro.dart`).
- **"10 de 18"** é a contagem de prompts com uma linha de import `package:sintonize/…` no corpo,
  contando a genérica do I-CRASH-COT. É a que responde à pergunta "quais prompts receberam ajuda
  de import"; sem a genérica, 9.
- Se a pergunta for "quais prompts informam o caminho do arquivo de alguma forma", são 15; só os
  três FS de widget/integração não trazem nada, e são exatamente os três cujo exemplo few-shot
  carrega o risco de alucinação de import que a Fase 1 mostrou.

Padrão por estratégia: todos os 6 COT têm linha de import (5 concretas + 1 genérica); dos ZS,
4 de 6 (os dois unitários só em prosa); dos FS, 0 de 6 com linha de import (2 em prosa, 1 em
comentário, 3 sem nada).
