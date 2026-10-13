import re
F = 'test/fase2-chatgpt-reexec/widget/wsilent_cot_test.dart'
R = 'fase2-chatgpt-reexec/rodadas/widget/FASE2-WSILENT-COT_transcricao/iter2_resposta.md'
src = open(F, encoding='utf-8').read()
resp = open(R, encoding='utf-8').read().split('\n')


def block(a, b):  # linhas de fence (1-based); conteúdo entre elas
    return '\n'.join(resp[a:b - 1])


def find_test(s, name):
    i = s.index("'" + name + "'")
    start = s.rindex('testWidgets(', 0, i)
    ls = s.rindex('\n', 0, start) + 1  # início da linha
    # casa parênteses a partir de 'testWidgets('
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
    end = j + 1
    if s[end] == ';':
        end += 1
    return ls, end


# remoções
for line in ["import 'package:mockito/mockito.dart';\n",
             'class MockFirebaseAuthWithMockito extends Mock implements FirebaseAuth {}\n',
             'class MockUserCredential extends Mock implements UserCredential {}\n']:
    assert src.count(line) == 1, line
    src = src.replace(line, '')

pairs = [
    ('deve aceitar e-mail e senha válidos', (43, 89)),
    ('não deve chamar Firebase quando o formulário for inválido', (103, 134)),
    ('deve chamar Firebase Auth com e-mail e senha corretos', (144, 175)),
    ('deve exibir mensagem correta para user-not-found', (196, 238)),
    ('deve exibir mensagem correta para wrong-password', (244, 286)),
    ('deve exibir mensagem correta para invalid-credential', (292, 334)),
    ('deve exibir mensagem genérica para erro de rede', (342, 384)),
    ('deve exibir mensagem genérica para código de erro desconhecido', (388, 430)),
]
for name, (a, b) in pairs:
    ls, end = find_test(src, name)
    src = src[:ls] + block(a, b) + src[end:]
open(F, 'w', encoding='utf-8', newline='\n').write(src)
print('ok', src.count('testWidgets('))
