#!/bin/bash
# ========================================
# Script de Seed para DynamoDB Local (Bash/Linux/Mac/WSL)
# ========================================
# Como usar: ./bash-seed-dynamodb.sh
# ========================================

TABLE_NAME="ton-marketplace-api-dev"
ENDPOINT="http://localhost:8000"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}🚀 Iniciando seed do DynamoDB Local...${NC}"
echo -e "${YELLOW}📦 Tabela: ${TABLE_NAME}${NC}"
echo -e "${YELLOW}🔗 Endpoint: ${ENDPOINT}\n${NC}"

# ========================================
# 1. VERIFICAR SE O DYNAMODB ESTÁ RODANDO
# ========================================
echo -e "${CYAN}🔍 Verificando conexão com DynamoDB Local...${NC}"
if aws dynamodb list-tables --endpoint-url ${ENDPOINT} &> /dev/null; then
    echo -e "${GREEN}✅ DynamoDB Local está rodando!\n${NC}"
else
    echo -e "${RED}❌ Erro: DynamoDB Local não está acessível em ${ENDPOINT}${NC}"
    echo -e "${YELLOW}💡 Certifique-se de que o container Docker está rodando.\n${NC}"
    exit 1
fi

# ========================================
# 2. VERIFICAR SE A TABELA JÁ EXISTE
# ========================================
echo -e "${CYAN}🔍 Verificando se a tabela existe...${NC}"
if aws dynamodb describe-table --table-name ${TABLE_NAME} --endpoint-url ${ENDPOINT} &> /dev/null; then
    echo -e "${YELLOW}⚠️  Tabela '${TABLE_NAME}' já existe!${NC}"
    read -p "Deseja recriar a tabela? (S/n): " response
    
    if [[ "$response" =~ ^[Nn]$ ]]; then
     echo -e "${YELLOW}⏭️  Pulando criação da tabela...\n${NC}"
        SKIP_TABLE_CREATION=true

       
    else
        echo -e "${YELLOW}🗑️  Deletando tabela existente...${NC}"
        aws dynamodb delete-table --table-name ${TABLE_NAME} --endpoint-url ${ENDPOINT} > /dev/null
        sleep 2
        echo -e "${GREEN}✅ Tabela deletada!\n${NC}"
    fi
fi

# ========================================
# 3. CRIAR TABELA
# ========================================
if [ -z "$SKIP_TABLE_CREATION" ]; then
    echo -e "${CYAN}📋 Criando tabela '${TABLE_NAME}'...${NC}"
    if aws dynamodb create-table \
        --table-name ${TABLE_NAME} \
        --attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S \
        --key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE \
        --billing-mode PAY_PER_REQUEST \
        --endpoint-url ${ENDPOINT} > /dev/null; then
        echo -e "${GREEN}✅ Tabela criada com sucesso!\n${NC}"
    else
        echo -e "${RED}❌ Erro ao criar tabela!\n${NC}"
        exit 1
    fi
fi

# ========================================
# 4. INSERIR PRODUTOS
# ========================================
echo -e "${CYAN}📦 Inserindo produtos...${NC}"

# Produto 1
echo -e "${GRAY}  → Máquina de Cartão T1...${NC}"
aws dynamodb put-item \
  --table-name ${TABLE_NAME} \
  --endpoint-url ${ENDPOINT} \
  --item '{
    "PK": {"S": "PRODUCTS"},
    "SK": {"S": "PRODUCT#01"},
    "name": {"S": "Máquina de Cartão T1"},
    "description": {"S": "A máquina de entrada, perfeita para começar."},
    "price": {"N": "11880"},
    "category": {"S": "maquinas"}
  }' > /dev/null

# Produto 2
echo -e "${GRAY}  → Máquina de Cartão T2+...${NC}"
aws dynamodb put-item \
  --table-name ${TABLE_NAME} \
  --endpoint-url ${ENDPOINT} \
  --item '{
    "PK": {"S": "PRODUCTS"},
    "SK": {"S": "PRODUCT#02"},
    "name": {"S": "Máquina de Cartão T2+"},
    "description": {"S": "Mais bateria e comprovante impresso."},
    "price": {"N": "23880"},
    "category": {"S": "maquinas"}
  }' > /dev/null

# Produto 3
echo -e "${GRAY}  → Bobina T2 (Pacote com 12)...${NC}"
aws dynamodb put-item \
  --table-name ${TABLE_NAME} \
  --endpoint-url ${ENDPOINT} \
  --item '{
    "PK": {"S": "PRODUCTS"},
    "SK": {"S": "PRODUCT#03"},
    "name": {"S": "Bobina T2 (Pacote com 12)"},
    "description": {"S": "Pacote de recarga de bobinas."},
    "price": {"N": "5000"},
    "category": {"S": "insumos"}
  }' > /dev/null

echo -e "${GREEN}✅ Produtos inseridos com sucesso!\n${NC}"

# ========================================
# 5. INSERIR USUÁRIO DE TESTE
# ========================================
echo -e "${CYAN}👤 Inserindo usuário de teste...${NC}"
aws dynamodb put-item \
  --table-name ${TABLE_NAME} \
  --endpoint-url ${ENDPOINT} \
  --item '{
    "PK": {"S": "USER#teste@ton.com"},
    "SK": {"S": "METADATA"},
    "name": {"S": "Usuário de Teste"},
    "passwordHash": {"S": "$2b$10$dlWbsFIAo1nSwHhDatba7eCv6..7I1bXucHoEx9ZRbl.rtPZfEbqS"},
    "role": {"S": "seller"}
  }' > /dev/null

echo -e "${GREEN}✅ Usuário inserido com sucesso!\n${NC}"

# ========================================
# 6. VERIFICAR DADOS INSERIDOS
# ========================================
echo -e "${CYAN}🔍 Verificando dados inseridos...${NC}"
COUNT=$(aws dynamodb scan --table-name ${TABLE_NAME} --endpoint-url ${ENDPOINT} --select COUNT | grep -oP '(?<="Count": )[0-9]+')
echo -e "${GREEN}✅ Total de itens na tabela: ${YELLOW}${COUNT}${NC}"

# ========================================
# RESUMO
# ========================================
echo -e "\n${CYAN}==================================================${NC}"
echo -e "${GREEN}✨ Seed concluído com sucesso!${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "\n${YELLOW}📊 Dados inseridos:${NC}"
echo -e "${WHITE}  • 3 Produtos (2 máquinas + 1 insumo)${NC}"
echo -e "${WHITE}  • 1 Usuário de teste (teste@ton.com)${NC}"
echo -e "\n${YELLOW}🔐 Credenciais de teste:${NC}"
echo -e "${WHITE}  Email: teste@ton.com${NC}"
echo -e "${WHITE}  Senha: Teste@123${NC}"
echo -e "\n${YELLOW}💡 Para visualizar os dados:${NC}"
echo -e "${GRAY}  aws dynamodb scan --table-name ${TABLE_NAME} --endpoint-url ${ENDPOINT}\n${NC}"