import sys, os, re, glob, csv, io
# uso: parse.py <fase2|fase3> <dir_lcov> <csv_saida> <resumo_md>
fase, d, out, resumo = sys.argv[1:5]
rows=[]; falhas=[]; UNION={}
def meta(id_):
    if fase=='fase2':
        tree, nivel, nome = id_.split('__')
        modelo = 'Gemini' if tree=='fase2-gemini' else 'ChatGPT'
        m = re.search(r'_(zs|fs|cot)$', nome); estr=m.group(1).upper()
        alvo = nome[:m.start()]
        nivel = {'unit':'unit','widget':'widget','integration':'integration'}[nivel]
        rodada = f"FASE2-{'UNIT' if nivel=='unit' else 'WIDGET' if nivel=='widget' else 'INT'}-{estr}_{alvo}"
        return rodada, modelo, nivel, estr
    else:
        modelo_dir, nome = id_.split('__')
        modelo = 'Gemini' if modelo_dir=='gemini' else 'ChatGPT'
        m = re.search(r'_(zs|fs|cot)$', nome); estr=m.group(1).upper(); alvo=nome[:m.start()]
        num={'login':'01','cadastro':'02','playlist':'03'}[alvo]
        return f"FASE3-E2E-{estr}-{num}_{alvo}Flow", modelo, 'e2e', estr
for lc in sorted(glob.glob(os.path.join(d,'*.lcov'))):
    id_=os.path.basename(lc)[:-5]; rodada,modelo,nivel,estr=meta(id_)
    cur=None; per={}
    for line in io.open(lc,encoding='utf-8'):
        line=line.strip()
        if line.startswith('SF:'):
            cur=line[3:].replace(chr(92),'/'); per[cur]={'lf':0,'lh':0,'da':{}}
        elif line.startswith('DA:'):
            ln,h=line[3:].split(',')[:2]; per[cur]['da'][int(ln)]=int(h)
        elif line.startswith('LF:'): per[cur]['lf']=int(line[3:])
        elif line.startswith('LH:'): per[cur]['lh']=int(line[3:])
    per={k:v for k,v in per.items() if k.startswith('lib/')}
    key=(nivel,estr,modelo); U=UNION.setdefault(key,{})
    for arq,v in per.items():
        u=U.setdefault(arq,{})
        for ln,h in v['da'].items(): u[ln]=u.get(ln,0)+h
    for arq,v in sorted(per.items()):
        rows.append([rodada,modelo,nivel,estr,arq,v['lh'],v['lf']])
    rows.append([rodada,modelo,nivel,estr,'TOTAL',sum(v['lh'] for v in per.values()),sum(v['lf'] for v in per.values())])
with io.open(out,'w',encoding='utf-8',newline='') as f:
    w=csv.writer(f); w.writerow(['rodada','modelo','nivel','estrategia','arquivo','linhas_cobertas','linhas_total']); w.writerows(rows)
# resumo nivel x estrategia x modelo (soma dos TOTAL)
agg={}
for r in rows:
    if r[4]!='TOTAL': continue
    k=(r[2],r[3],r[1]); a=agg.setdefault(k,[0,0,[]]); a[0]+=r[5]; a[1]+=r[6]; a[2].append(100*r[5]/r[6] if r[6] else 0)
lines=['| nível | estratégia | modelo | rodadas medidas | média % por rodada | união: linhas cobertas | união: linhas total | união % |','|---|---|---|---|---|---|---|---|']
for k in sorted(agg):
    lh,lf,pcts=agg[k]; U=UNION[k]
    ulh=sum(1 for a in U.values() for h in a.values() if h>0); ulf=sum(len(a) for a in U.values())
    lines.append(f"| {k[0]} | {k[1]} | {k[2]} | {len(pcts)} | {sum(pcts)/len(pcts):.1f} | {ulh} | {ulf} | {100*ulh/ulf if ulf else 0:.1f} |")
io.open(resumo,'w',encoding='utf-8').write('\n'.join(lines)+'\n')
print('\n'.join(lines))
