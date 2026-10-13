#!/bin/bash
# roda cobertura dos 18 testes limpos da Fase 3 no worktree, com seed antes de cada um
set -u
R="/c/Users/marcos.neto/desktop/Repositórios/sintonize-tcc"
W=/c/Users/marcos.neto/Desktop/sintonize-fase3
OUT="$TMP/cov/fase3"; mkdir -p "$OUT"; touch "$OUT/log.txt"
P=sintonize-fa494; H="Authorization: Bearer owner"
export JAVA_HOME="$LOCALAPPDATA/jdk17/jdk-17.0.20.1+1"
start=$(date +%s)
for m in chatgpt gemini; do for f in login_zs login_fs login_cot cadastro_zs cadastro_fs cadastro_cot playlist_zs playlist_fs playlist_cot; do
  id="${m}__${f}"; src="$R/integration_test/fase3/$m/${f}_test.dart"; dst="$W/integration_test/fase3/cov_${f}_test.dart"
  grep -q "^$id " "$OUT/log.txt" && continue
  cp "$src" "$dst"
  # reinicia emuladores Firebase (vazios) 
  powershell -NoProfile -c "Get-CimInstance Win32_Process -Filter \"Name='java.exe' or Name='node.exe'\" | ? { \$_.CommandLine -match 'firestore|firebase' } | % { Stop-Process -Id \$_.ProcessId -Force }" 2>/dev/null
  sleep 3
  powershell -NoProfile -c "Start-Process -WindowStyle Hidden -FilePath cmd -ArgumentList '/c cd /d $(cygpath -w "$R") && firebase emulators:start --only auth,firestore --project $P > %TEMP%\\claude\\fb.log 2>&1'"
  for i in $(seq 1 60); do fs=$(curl -s -o /dev/null -w "%{http_code}" localhost:8080); au=$(curl -s -o /dev/null -w "%{http_code}" localhost:9099); [ "$fs" = 200 ] && [ "$au" = 200 ] && break; sleep 2; done
  [ "$fs" = 200 ] || { echo "$id EMULADORES FORA" >> "$OUT/log.txt"; rm -f "$dst"; continue; }
  (cd $W && flutter test integration_test/seed_test.dart -d emulator-5554 > "$OUT/$id.seed.log" 2>&1)
  grep -q "All tests passed" "$OUT/$id.seed.log" || { echo "$id SEED FALHOU" >> "$OUT/log.txt"; rm -f "$dst"; continue; }
  au=$(curl -s -X POST -H "$H" -H "Content-Type: application/json" -d '{}' "localhost:9099/identitytoolkit.googleapis.com/v1/projects/$P/accounts:query" | grep -o '"recordsCount": *"[0-9]*"' | grep -o '[0-9]*')
  us=$(curl -s -H "$H" "localhost:8080/v1/projects/$P/databases/(default)/documents/usuarios?pageSize=100" | grep -c '"name": "projects')
  mu=$(curl -s -H "$H" "localhost:8080/v1/projects/$P/databases/(default)/documents/musica?pageSize=100" | grep -c '"name": "projects')
  [ "$au" = 1 ] && [ "$us" = 1 ] && [ "$mu" = 5 ] || { echo "$id SEED $au/$us/$mu != 1/1/5" >> "$OUT/log.txt"; rm -f "$dst"; continue; }
  rm -f "$W/coverage/lcov.info"; t0=$(date +%s)
  (cd $W && timeout -k 10 600 flutter test --coverage "integration_test/fase3/cov_${f}_test.dart" -d emulator-5554 > "$OUT/$id.out" 2>&1); rc=$?
  [ -f "$W/coverage/lcov.info" ] && cp "$W/coverage/lcov.info" "$OUT/$id.lcov"
  echo "$id rc=$rc lcov=$([ -f "$W/coverage/lcov.info" ] && echo sim || echo nao) $(( $(date +%s) - t0 ))s $(grep -oE '^[0-9:]+ \+[0-9]+( -[0-9]+)?: (All tests passed|Some tests failed)' "$OUT/$id.out" | tail -1)" >> "$OUT/log.txt"
  rm -f "$dst"
done; done
powershell -NoProfile -c "Get-CimInstance Win32_Process -Filter \"Name='java.exe'\" | ? { \$_.CommandLine -match 'GradleDaemon|kotlin' } | % { Stop-Process -Id \$_.ProcessId -Force }" 2>/dev/null
echo "TOTAL $(( $(date +%s) - start ))s" >> "$OUT/log.txt"
