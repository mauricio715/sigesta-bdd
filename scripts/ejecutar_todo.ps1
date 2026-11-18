# Automatiza: servidores de SI-GESTA -> versiones -> mvn clean verify -> git/GitHub
# Uso: ejecutar_todo.bat  (o: powershell -ExecutionPolicy Bypass -File scripts\ejecutar_todo.ps1 [-SinGit] [-SinPruebas])
param([switch]$SinGit, [switch]$SinPruebas)

$ErrorActionPreference = 'Continue'
$Proyecto = Split-Path -Parent $PSScriptRoot
$Sigesta  = Join-Path (Split-Path -Parent $Proyecto) 'sigesta'
$Logs     = Join-Path $Proyecto 'logs'
New-Item -ItemType Directory -Force $Logs | Out-Null
Start-Transcript -Path (Join-Path $Logs 'ejecucion.log') -Force | Out-Null

function Paso($t) { Write-Host ""; Write-Host "==================== $t ====================" }

function Url-Activa($url) {
    try { $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5; return "OK $($r.StatusCode)" }
    catch {
        if ($_.Exception.Response) { return "OK $([int]$_.Exception.Response.StatusCode)" }
        return $null
    }
}

function Puerto-Activo($p) {
    foreach ($h in @('127.0.0.1', '::1')) {
        try { $c = New-Object Net.Sockets.TcpClient; $c.Connect($h, $p); $c.Close(); return $true } catch { }
    }
    return $false
}

function Esperar-Url($url, $seg) {
    for ($i = 0; $i -lt $seg; $i += 3) { $e = Url-Activa $url; if ($e) { return $e }; Start-Sleep 3 }
    return $null
}

function Buscar-Exe($nombre, $patrones) {
    $c = Get-Command $nombre -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($p in $patrones) {
        $f = Get-ChildItem -Path $p -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
        if ($f) { return $f.FullName }
    }
    return $null
}

$Resumen = [ordered]@{}

# ------------------------------------------------------------------ FASE 1
Paso "FASE 1: Servidores de SI-GESTA"
Write-Host "Disco C libre (GB): $([math]::Round((Get-PSDrive C).Free/1GB,2))"
$env:SIGESTA_DIR  = $Sigesta
$env:SIGESTA_LOGS = $Logs

$Resumen['MySQL 3306'] = if (Puerto-Activo 3306) { 'activo' } else { 'NO responde (encienda MySQL en Laragon)' }
Write-Host "MySQL :3306 -> $($Resumen['MySQL 3306'])"

# Backend Laravel
$estado = Url-Activa 'http://127.0.0.1:8000/up'
if (-not $estado) { $estado = Url-Activa 'http://127.0.0.1:8000/' }
if ($estado) { $Resumen['Backend :8000'] = "ya estaba activo ($estado)" }
else {
    $php = Buscar-Exe 'php' @('C:\laragon\bin\php\php-8*\php.exe', 'D:\laragon\bin\php\php-8*\php.exe', 'C:\xampp\php\php.exe')
    Write-Host "PHP: $php"
    $env:SIGESTA_PHP = $php
    Start-Process cmd.exe -ArgumentList '/c', "`"$PSScriptRoot\levantar_backend.cmd`"" -WindowStyle Minimized
    $estado = Esperar-Url 'http://127.0.0.1:8000/up' 60
    $Resumen['Backend :8000'] = if ($estado) { "levantado ($estado)" } else { 'NO arranco (ver logs\backend.log)' }
}
Write-Host "Backend -> $($Resumen['Backend :8000'])"

# Microservicio IA
$estado = Url-Activa 'http://127.0.0.1:8001/docs'
if ($estado) { $Resumen['ai-service :8001'] = "ya estaba activo ($estado)" }
else {
    Start-Process cmd.exe -ArgumentList '/c', "`"$PSScriptRoot\levantar_ia.cmd`"" -WindowStyle Minimized
    $estado = Esperar-Url 'http://127.0.0.1:8001/docs' 60
    $Resumen['ai-service :8001'] = if ($estado) { "levantado ($estado)" } else { 'NO arranco (ver logs\ai-service.log)' }
}
Write-Host "ai-service -> $($Resumen['ai-service :8001'])"

# Frontend Vite
$estado = Url-Activa 'http://localhost:5173/'
if ($estado) { $Resumen['Frontend :5173'] = "ya estaba activo ($estado)" }
else {
    $npm = Buscar-Exe 'npm.cmd' @('C:\Program Files\nodejs\npm.cmd', 'C:\laragon\bin\nodejs\node-*\npm.cmd')
    Write-Host "npm: $npm"
    $env:SIGESTA_NPM = $npm
    Start-Process cmd.exe -ArgumentList '/c', "`"$PSScriptRoot\levantar_frontend.cmd`"" -WindowStyle Minimized
    $estado = Esperar-Url 'http://localhost:5173/' 90
    $Resumen['Frontend :5173'] = if ($estado) { "levantado ($estado)" } else { 'NO arranco (ver logs\frontend.log)' }
}
Write-Host "Frontend -> $($Resumen['Frontend :5173'])"

# Comprobacion de API a traves del proxy de Vite (credencial del DemoSeeder)
try {
    $body = '{"email":"admin@sigesta.com","password":"password"}'
    $r = Invoke-WebRequest -Uri 'http://localhost:5173/api/v1/auth/login' -Method Post -Body $body -ContentType 'application/json' -Headers @{Accept='application/json'} -UseBasicParsing -TimeoutSec 20
    $Resumen['Login API admin'] = "OK $($r.StatusCode)"
    $token = ($r.Content | ConvertFrom-Json)
    $tk = $token.token; if (-not $tk) { $tk = $token.data.token }; if (-not $tk) { $tk = $token.access_token }
    if ($tk) {
        $l = Invoke-WebRequest -Uri 'http://localhost:5173/api/v1/lotes?buscar=LEC-LV-2609' -Headers @{Authorization="Bearer $tk"; Accept='application/json'} -UseBasicParsing -TimeoutSec 20
        $Resumen['Lote LEC-LV-2609'] = if ($l.Content -match 'LEC-LV-2609') { 'existe en BD' } else { 'NO encontrado' }
        Write-Host ("Respuesta lotes (recorte): " + $l.Content.Substring(0, [Math]::Min(600, $l.Content.Length)))
    } else { Write-Host ("Respuesta login (recorte): " + $r.Content.Substring(0, [Math]::Min(400, $r.Content.Length))) }
} catch { $Resumen['Login API admin'] = "ERROR: $($_.Exception.Message)" }
Write-Host "Login API -> $($Resumen['Login API admin']) | Lote -> $($Resumen['Lote LEC-LV-2609'])"

# ------------------------------------------------------------------ FASE 3
Paso "FASE 3: Versiones"
$java = Buscar-Exe 'java' @("$env:JAVA_HOME\bin\java.exe", 'C:\Program Files\Java\jdk-*\bin\java.exe', 'C:\Program Files\Eclipse Adoptium\jdk-*\bin\java.exe', 'D:\Java\jdk-*\bin\java.exe', 'D:\jdk-*\bin\java.exe')
$mvn  = Buscar-Exe 'mvn.cmd' @('D:\apache-maven-*\bin\mvn.cmd', 'D:\*\apache-maven-*\bin\mvn.cmd', 'C:\apache-maven-*\bin\mvn.cmd', 'C:\Program Files\apache-maven-*\bin\mvn.cmd', 'C:\Program Files\Maven\apache-maven-*\bin\mvn.cmd', 'D:\*\*\apache-maven-*\bin\mvn.cmd')
$git  = Buscar-Exe 'git' @('C:\Program Files\Git\cmd\git.exe')
$gh   = Buscar-Exe 'gh' @('C:\Program Files\GitHub CLI\gh.exe')
Write-Host "java=$java"; Write-Host "mvn=$mvn"; Write-Host "git=$git"; Write-Host "gh=$gh"
if ($java -and -not $env:JAVA_HOME) { $env:JAVA_HOME = Split-Path -Parent (Split-Path -Parent $java) }
if ($java) { & $java -version 2>&1 | ForEach-Object { "$_" } }
if ($mvn)  { & $mvn -version 2>&1 | ForEach-Object { "$_" } }
if ($git)  { & $git --version }

# ------------------------------------------------------------------ FASE 4
$ok = $false
if (-not $SinPruebas) {
    Paso "FASE 4: mvn clean verify"
    Push-Location $Proyecto
    & $mvn -B clean verify 2>&1 | ForEach-Object { "$_" } | Out-File -Encoding utf8 (Join-Path $Logs 'mvn.log')
    $codigo = $LASTEXITCODE
    Pop-Location
    Write-Host "Codigo de salida de Maven: $codigo"
    Get-Content (Join-Path $Logs 'mvn.log') -Tail 60
    $sum = Join-Path $Proyecto 'target\failsafe-reports\failsafe-summary.xml'
    if (Test-Path $sum) { [xml]$x = Get-Content $sum; $Resumen['Pruebas'] = "completadas=$($x.'failsafe-summary'.completed) errores=$($x.'failsafe-summary'.errors) fallos=$($x.'failsafe-summary'.failures) omitidas=$($x.'failsafe-summary'.skipped)" }
    $idx = Join-Path $Proyecto 'target\site\serenity\index.html'
    $Resumen['Reporte Serenity'] = if (Test-Path $idx) { $idx } else { 'NO generado' }
    $ok = ($codigo -eq 0) -and (Test-Path $idx)
    $Resumen['mvn clean verify'] = if ($ok) { 'BUILD SUCCESS' } else { "FALLO (codigo $codigo)" }
}

if ($ok -and -not $SinGit) {
    Paso "FASE 4: Git y GitHub"
    Push-Location $Proyecto
    if (-not (Test-Path '.git')) { & $git init -b main }
    $nombre = & $git config user.name; $correo = & $git config user.email
    if (-not $nombre) { & $git config user.name 'Andrew Gonzales Butron' }
    if (-not $correo) {
        $login = $null; if ($gh) { $login = & $gh api user --jq .login 2>$null }
        if ($login) { & $git config user.email "$login@users.noreply.github.com" } else { & $git config user.email 'sigesta-bdd@localhost' }
    }
    & $git add -A
    & $git status --short
    $msg = Join-Path $Logs 'commit_msg.txt'
    @(
        'Proyecto BDD E2E de SI-GESTA con Serenity + Cucumber (Gherkin en espanol)',
        '',
        '3 escenarios: login de administrador, trazabilidad del lote LEC-LV-2609 y prediccion de demanda.',
        '',
        'Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>',
        'Claude-Session: https://claude.ai/code/session_015z6f1LHbnUR3gqUe2Dqsfe'
    ) | Out-File -Encoding utf8 $msg
    & $git commit -F $msg
    & $git log --oneline -n 3
    if ($gh) {
        & $gh auth status 2>&1 | ForEach-Object { "$_" }
        if ($LASTEXITCODE -eq 0) {
            $remoto = & $git remote
            if (-not $remoto) { & $gh repo create sigesta-bdd --public --source=. --remote=origin --push 2>&1 | ForEach-Object { "$_" } }
            else { & $git push -u origin main 2>&1 | ForEach-Object { "$_" } }
            $Resumen['GitHub'] = (& $gh repo view --json url -q .url 2>&1)
        } else { $Resumen['GitHub'] = 'gh NO autenticado' }
    } else { $Resumen['GitHub'] = 'GitHub CLI (gh) no instalado' }
    Pop-Location
}

Paso "RESUMEN"
$Resumen.GetEnumerator() | ForEach-Object { "{0,-20}: {1}" -f $_.Key, $_.Value } | Tee-Object -FilePath (Join-Path $Logs 'resumen.txt')
Stop-Transcript | Out-Null
