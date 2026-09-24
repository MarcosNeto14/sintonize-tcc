"""Aplica, sem alterar nenhum token, os patches da resposta ao reparo 2 (iter2_resposta.md).
Rodar da raiz do repositório.

Aplicados (âncora presente no arquivo):
1. Helpers `tapVisible` e `enterTextVisible` inseridos após os imports.
2. "substitua [bloco 45-53] por [bloco 59-73]" — todas as ocorrências (2).
3. Teste 'não cadastra quando o nome está vazio' substituído pelo bloco 83-131.
4. "No teste de sucesso, troque [expect(auth.currentUser, isNotNull);] por [bloco 226-235]".

Não aplicados (sem âncora no arquivo): os trechos de GenerosCadastroScreen (blocos 139-151 e
155-166, mostrados sem o código que substituem) e a instrução genérica "a mesma alteração deve
ser aplicada aos quatro testes de validação, ao teste de erro do Auth, ao teste de erro do
Firestore e ao E2E", que exigiria o operador reescrever testes com código diferente do exemplo.
"""
import re

F = 'test/fase2-chatgpt-reexec/integration/icrash_cot_test.dart'
R = 'fase2-chatgpt-reexec/rodadas/integration/FASE2-ICRASH-COT_transcricao/iter2_resposta.md'
s = open(F, encoding='utf-8').read()
L = open(R, encoding='utf-8').read().split('\n')


def blk(a, b):  # a e b são as linhas (1-based) das cercas ```
    return '\n'.join(L[a:b - 1])


def pat(x):
    return re.compile(r'\s*'.join(re.escape(t) for t in re.split(r'\s+', x.strip())))


# 1. helpers após o último import
last_imp = max(m.end() for m in re.finditer(r"^import .*;$", s, re.M))
s = s[:last_imp] + '\n\n' + blk(21, 41) + '\n' + s[last_imp:]

# 2. cadastro
p = pat(blk(45, 53))
n2 = len(p.findall(s))
s = p.sub(lambda m: blk(59, 73), s)

# 3. teste de validação do nome
i = s.index("'não cadastra quando o nome está vazio'")
start = s.rindex('testWidgets(', 0, i)
ls = s.rindex('\n', 0, start) + 1
depth, j, q = 0, start + len('testWidgets'), None
while True:
    c = s[j]
    if q:
        if c == '\\':
            j += 2
            continue
        if c == q:
            q = None
    elif c in "'\"":
        q = c
    elif c == '(':
        depth += 1
    elif c == ')':
        depth -= 1
        if depth == 0:
            break
    j += 1
end = j + 1 + (1 if s[j + 1] == ';' else 0)
s = s[:ls] + blk(83, 131) + s[end:]

# 4. teste de sucesso
p = pat(blk(220, 222))
n4 = len(p.findall(s))
assert n4 == 1
s = p.sub(lambda m: blk(226, 235), s)

open(F, 'w', encoding='utf-8', newline='\n').write(s)
print('cadastro', n2, 'sucesso', n4)
