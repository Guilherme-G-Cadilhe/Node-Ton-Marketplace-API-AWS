#!/usr/bin/env pwsh
# ========================================
# Script de Seed para DynamoDB Local (Windows/PowerShell)
# ========================================
# Como usar: .\windows-seed-dynamodb.ps1
# ========================================

$TABLE_NAME = "ton-marketplace-api-dev"
$ENDPOINT = "http://localhost:8000"

Write-Host ""
Write-Host "Iniciando seed do DynamoDB Local..." -ForegroundColor Cyan
Write-Host "Tabela: $TABLE_NAME" -ForegroundColor Yellow
Write-Host "Endpoint: $ENDPOINT" -ForegroundColor Yellow
Write-Host ""

# ========================================
# 1. VERIFICAR SE O DYNAMODB ESTA RODANDO
# ========================================
Write-Host "Verificando conexao com DynamoDB Local..." -ForegroundColor Cyan
try {
    $null = aws dynamodb list-tables --endpoint-url $ENDPOINT 2>&1
    Write-Host "DynamoDB Local esta rodando!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "Erro: DynamoDB Local nao esta acessivel em $ENDPOINT" -ForegroundColor Red
    Write-Host "Certifique-se de que o container Docker esta rodando." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# ========================================
# 2. VERIFICAR SE A TABELA JA EXISTE
# ========================================
Write-Host "Verificando se a tabela existe..." -ForegroundColor Cyan
$tableExists = aws dynamodb describe-table --table-name $TABLE_NAME --endpoint-url $ENDPOINT 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Tabela '$TABLE_NAME' ja existe!" -ForegroundColor Yellow
    $response = Read-Host "Deseja recriar a tabela? (S/n)"
    
    if ($response -eq 'n' -or $response -eq 'N') {
        Write-Host "Pulando criacao da tabela..." -ForegroundColor Yellow
        Write-Host ""
        $skipTableCreation = $true
    } else {
       


         Write-Host "Deletando tabela existente..." -ForegroundColor Yellow
        aws dynamodb delete-table --table-name $TABLE_NAME --endpoint-url $ENDPOINT | Out-Null
        Start-Sleep -Seconds 2
        Write-Host "Tabela deletada!" -ForegroundColor Green
        Write-Host ""
    }
}

# ========================================
# 3. CRIAR TABELA
# ========================================
if (-not $skipTableCreation) {
    Write-Host "Criando tabela '$TABLE_NAME'..." -ForegroundColor Cyan
    aws dynamodb create-table `
        --table-name $TABLE_NAME `
        --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S `
        --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE `
        --billing-mode PAY_PER_REQUEST `
        --endpoint-url $ENDPOINT | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Tabela criada com sucesso!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "Erro ao criar tabela!" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

# ========================================
# 4. INSERIR PRODUTOS
# ========================================
Write-Host "Inserindo produtos..." -ForegroundColor Cyan

# Produto 1
Write-Host "  -> Maquina de Cartao T1..." -ForegroundColor Gray
aws dynamodb put-item `
  --table-name $TABLE_NAME `
  --endpoint-url $ENDPOINT `
  --item '{\"PK\": {\"S\": \"PRODUCTS\"},\"SK\": {\"S\": \"PRODUCT#01\"},\"name\": {\"S\": \"Maquina de Cartao T1\"},\"description\": {\"S\": \"A maquina de entrada, perfeita para comecar.\"},\"price\": {\"N\": \"11880\"},\"category\": {\"S\": \"maquinas\"}}' | Out-Null

# Produto 2
Write-Host "  -> Maquina de Cartao T2+..." -ForegroundColor Gray
aws dynamodb put-item `
  --table-name $TABLE_NAME `
  --endpoint-url $ENDPOINT `
  --item '{\"PK\": {\"S\": \"PRODUCTS\"},\"SK\": {\"S\": \"PRODUCT#02\"},\"name\": {\"S\": \"Maquina de Cartao T2+\"},\"description\": {\"S\": \"Mais bateria e comprovante impresso.\"},\"price\": {\"N\": \"23880\"},\"category\": {\"S\": \"maquinas\"}}' | Out-Null

# Produto 3
Write-Host "  -> Bobina T2 (Pacote com 12)..." -ForegroundColor Gray
aws dynamodb put-item `
  --table-name $TABLE_NAME `
  --endpoint-url $ENDPOINT `
  --item '{\"PK\": {\"S\": \"PRODUCTS\"},\"SK\": {\"S\": \"PRODUCT#03\"},\"name\": {\"S\": \"Bobina T2 (Pacote com 12)\"},\"description\": {\"S\": \"Pacote de recarga de bobinas.\"},\"price\": {\"N\": \"5000\"},\"category\": {\"S\": \"insumos\"}}' | Out-Null

Write-Host "Produtos inseridos com sucesso!" -ForegroundColor Green
Write-Host ""

# ========================================
# 5. INSERIR USUARIO DE TESTE
# ========================================
Write-Host "Inserindo usuario de teste..." -ForegroundColor Cyan
aws dynamodb put-item `
  --table-name $TABLE_NAME `
  --endpoint-url $ENDPOINT `
  --item '{\"PK\": {\"S\": \"USER#teste@ton.com\"},\"SK\": {\"S\": \"METADATA\"},\"name\": {\"S\": \"Usuario de Teste\"},\"passwordHash\": {\"S\": \"$2b$10$dlWbsFIAo1nSwHhDatba7eCv6..7I1bXucHoEx9ZRbl.rtPZfEbqS\"},\"role\": {\"S\": \"seller\"}}' | Out-Null

Write-Host "Usuario inserido com sucesso!" -ForegroundColor Green
Write-Host ""

# ========================================
# 6. VERIFICAR DADOS INSERIDOS
# ========================================
Write-Host "Verificando dados inseridos..." -ForegroundColor Cyan
$scanResult = aws dynamodb scan --table-name $TABLE_NAME --endpoint-url $ENDPOINT --select COUNT

if ($LASTEXITCODE -eq 0) {
    Write-Host "Total de itens na tabela: " -ForegroundColor Green -NoNewline
    $count = ($scanResult | ConvertFrom-Json).Count
    Write-Host "$count" -ForegroundColor Yellow
}

# ========================================
# RESUMO
# ========================================
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Seed concluido com sucesso!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dados inseridos:" -ForegroundColor Yellow
Write-Host "  - 3 Produtos (2 maquinas + 1 insumo)" -ForegroundColor White
Write-Host "  - 1 Usuario de teste (teste@ton.com)" -ForegroundColor White
Write-Host ""
Write-Host "Credenciais de teste:" -ForegroundColor Yellow
Write-Host "  Email: teste@ton.com" -ForegroundColor White
Write-Host "  Senha: Teste@123" -ForegroundColor White
Write-Host ""
Write-Host "Para visualizar os dados:" -ForegroundColor Yellow
Write-Host "  aws dynamodb scan --table-name $TABLE_NAME --endpoint-url $ENDPOINT" -ForegroundColor Gray
Write-Host ""