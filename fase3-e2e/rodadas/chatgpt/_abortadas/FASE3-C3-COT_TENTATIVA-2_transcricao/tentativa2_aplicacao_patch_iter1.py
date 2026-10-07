# Aplicação do reparo 1 da tentativa 2 (FASE3-C3-COT, ChatGPT), 2026-10-06.
# A resposta não traz arquivo completo: diz "a parte final de fillValidRegistration()
# deve ficar assim:" e dá o bloco literal (do enterText de fields.at(7) até o último
# pumpAndSettle da seleção de SP), com "O restante do teste pode permanecer como estava."
# Este script troca, no arquivo da iteração 0, o trecho correspondente (do mesmo
# enterText até o '}' que fecha o `if (dropdownWidget.value == null) {`) pelo bloco
# literal da resposta, sem nenhuma outra edição. Uso: python <este> <iter0.dart> <resposta.md> <saida.dart>
import io, sys
src, resp, out = sys.argv[1:4]
code = io.open(src, encoding='utf-8').read()
R = io.open(resp, encoding='utf-8').read().split('\n')
i = next(k for k, l in enumerate(R) if l.startswith('Para facilitar a substituição, a parte final de fillValidRegistration()'))
j = next(k for k, l in enumerate(R) if l.startswith('O restante do teste pode permanecer como estava.'))
novo = R[i + 1:j]
while novo and novo[0].strip() == '': novo.pop(0)
while novo and novo[-1].strip() == '': novo.pop()
novo = '\n'.join(novo)
ini_marker = '    await tester.enterText(\n      fields.at(7),\n      numero,\n    );'
assert code.count(ini_marker) == 1
a = code.index(ini_marker)
fim_marker = "      await tester.tap(find.text('SP').last);\n      await tester.pumpAndSettle();\n    }\n"
assert code.count(fim_marker) == 1
b = code.index(fim_marker) + len(fim_marker)
velho = code[a:b]
assert 'dropdownWidget.value' in velho
res = code[:a] + novo + '\n' + code[b:]
io.open(out, 'w', encoding='utf-8', newline='\n').write(res)
print('trecho antigo:', len(velho), 'chars; novo:', len(novo), 'chars; arquivo:', len(res), 'chars')
