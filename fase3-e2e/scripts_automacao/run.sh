#!/bin/bash
# uso: run.sh <arquivo_teste_rel_ao_worktree> <saida.txt> <print.png>
# Espera emuladores, seed, confere 1/1/5 (bloqueia se diferente), executa e salva saída e print.
set -u
W=${W:-/c/Users/marcos.neto/Desktop/sintonize-fase3}
P=sintonize-fa494; H="Authorization: Bearer owner"
export JAVA_HOME="$LOCALAPPDATA/jdk17/jdk-17.0.20.1+1"
for i in $(seq 1 60); do
  f=$(curl -s -o /dev/null -w "%{http_code}" localhost:8080); a=$(curl -s -o /dev/null -w "%{http_code}" localhost:9099)
  [ "$f" = 200 ] && [ "$a" = 200 ] && break; sleep 2
done
[ "$f" = 200 ] || { echo "EMULADORES FORA"; exit 1; }
# os emuladores precisam estar vazios antes do seed
n0=$(curl -s -H "$H" -X POST -H "Content-Type: application/json" -d '{}' "localhost:8080/v1/projects/$P/databases/(default)/documents:listCollectionIds" | grep -c '"')
cd $W && flutter test integration_test/seed_test.dart -d emulator-5554 > "$TEMP/claude/seed.log" 2>&1
grep -q "All tests passed" "$TEMP/claude/seed.log" || { echo "SEED FALHOU"; tail -n 5 "$TEMP/claude/seed.log"; exit 1; }
au=$(curl -s -X POST -H "$H" -H "Content-Type: application/json" -d '{}' "localhost:9099/identitytoolkit.googleapis.com/v1/projects/$P/accounts:query" | grep -o '"recordsCount": *"[0-9]*"' | grep -o '[0-9]*')
us=$(curl -s -H "$H" "localhost:8080/v1/projects/$P/databases/(default)/documents/usuarios?pageSize=100" | grep -c '"name": "projects')
mu=$(curl -s -H "$H" "localhost:8080/v1/projects/$P/databases/(default)/documents/musica?pageSize=100" | grep -c '"name": "projects')
cols=$(curl -s -H "$H" -X POST -H "Content-Type: application/json" -d '{}' "localhost:8080/v1/projects/$P/databases/(default)/documents:listCollectionIds" | tr -d ' \n')
echo "seed: auth=$au usuarios=$us musica=$mu colecoes=$cols"
[ "$au" = 1 ] && [ "$us" = 1 ] && [ "$mu" = 5 ] || { echo "SEED DIFERENTE DE 1/1/5 - NAO EXECUTO"; exit 1; }
flutter test "$1" -d emulator-5554 > "$2" 2>&1
adb -s emulator-5554 exec-out screencap -p > "$3"
grep -E "^[0-9]{2}:[0-9]{2} \+" "$2" | tail -n 3
# libera memoria: encerra daemons do Gradle/Kotlin ao fim da execucao
powershell -NoProfile -c "Get-CimInstance Win32_Process -Filter \"Name='java.exe'\" | ? { \$_.CommandLine -match 'GradleDaemon|kotlin-compiler|KotlinCompileDaemon' } | % { Stop-Process -Id \$_.ProcessId -Force }" 2>/dev/null
