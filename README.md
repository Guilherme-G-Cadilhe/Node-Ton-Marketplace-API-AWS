# Desafio de Backend: Ton Marketplace API

API robusta e escalável construída para o desafio de Software Engineer Pleno (SWE III) da Stone/Ton, focada em performance, qualidade de código e alinhamento com a arquitetura Serverless-First da Stone.

O projeto implementa todos os requisitos obrigatórios e "Plus"

## 🚀 Arquitetura da Solução (AWS Serverless)

A arquitetura é 100% Serverless, otimizada para performance, custo (Free Tier) e alinhada com a stack principal da Stone.

```text
                                    ┌──────────────────────────┐
                                    │        Cliente           │
                                    │ (Front-end / Postman)    │
                                    └────────────┬─────────────┘
                                                 │
                                                 ▼
                                    ┌──────────────────────────┐
                                    │    API Gateway (HTTP)    │
                                    │ - /auth/login (POST)     │
                                    │ - /products (GET)        │
                                    └────────────┬─────────────┘
                                                 │
                              Valida JWT via     │
                              Custom Authorizer  │
                                                 ▼
                                  ┌────────────────────────┐
                                  │   jwtAuthorizer        │
                                  │ (Lambda Authorizer)    │
                                  └────────────┬───────────┘
                                               │
                        ┌──────────────────────┼──────────────────────┐
                        │                      │                      │
                        ▼                      ▼                      ▼
            ┌──────────────────┐     ┌────────────────────────────────────┐
            │  authLogin        │     │  getProducts                      │
            │  (Lambda)         │     │  (Lambda)                         │
            │------------------│     │------------------------------------│
            │ - Autentica user │     │ - Valida JWT (via Authorizer)     │
            │ - Gera JWT       │     │ - Executa Rate Limiter interno    │
            │                  │     │ - Consulta produtos no DynamoDB   │
            └────────┬─────────┘     └──────────────┬────────────────────┘
                     │                              │
                     └──────────────┬───────────────┘
                                    ▼
                             ┌────────────────────────────┐
                             │        DynamoDB            │
                             │ (Single-Table: Users,      │
                             │  Products, RateLimiter)    │
                             └────────────────────────────┘
                                               │
                                               ▼
                                   ┌────────────────────────┐
                                   │     CloudWatch Logs    │
                                   │ (Monitoring & Métricas)│
                                   └────────────────────────┘


```

- **API Gateway (HTTP API):** Gerencia os endpoints, rotas e CORS.
- **AWS Lambda (Node.js 20.x):** Executa a lógica de negócio (stateless).
- **DynamoDB (Single-Table):** Banco de dados NoSQL performático para persistência de Usuários, Produtos e estado do Rate Limiter.
- **Custom Authorizer:** Uma Lambda dedicada que valida tokens JWT, protegendo as rotas privadas de forma centralizada.
- **CloudWatch:** Coleta logs de todas as Lambdas, essencial para o troubleshooting

## ✨ Features Implementadas

- [x] **Autenticação JWT:** Endpoint `POST /auth/login` seguro com `bcrypt`.
- [x] **Rota Protegida:** Endpoint `GET /products` validado via `jwtAuthorizer`.
- [x] **Paginação (Cursor-Based):** Paginação performática no DynamoDB, retornando um cursor Base64 opaco.
- [x] **Rate Limiting (Token Bucket):** Proteção de rota com 100 req/min por usuário, persistido no DynamoDB.
- [x] **Testes de Unidade (100%):** Cobertura de 100% em toda a camada de _Serviços_ (auth, products, rate-limiter) usando Jest e Mocks.
- [x] **Qualidade de Código:** Configurado com ESLint, Prettier e Commits Semânticos (commitzen).
- [x] **Documentação de API:** Arquivo `openapi.json` gerado automaticamente (veja como rodar abaixo).
- [x] **Documentação de Arquitetura (ADRs):** Decisões de design documentadas em `docs/adrs/`.

---

## 📁 Estrutura do Projeto

A estrutura do projeto segue princípios de SOLID e separação de responsabilidades (SoC), facilitando manutenção, escalabilidade e testes.

```text
ton-marketplace-api/
├── docs/
│   └── adrs/                 # Decisões de arquitetura (ADRs)
├── seeds/                    # Scripts para popular o banco
├── src/
│   ├── authorizers/          # Lambdas de autorização (JWT)
│   ├── config/               # Configuração de clientes (DynamoDB)
│   ├── handlers/             # Camada HTTP (Request/Response)
│   ├── models/               # Tipos e interfaces (Entities)
│   ├── repositories/         # Camada de acesso a dados (Data Access)
│   ├── schemas/              # Validação de entrada (Zod)
│   └── services/             # Lógica de negócio (Business Logic)
├── tests/
│   └── unit/                 # Testes unitários da camada de serviços
├── .gitignore
├── eslint.config.js          # Regras de lint
├── jest.config.js            # Configuração do Jest
├── openapi.json              # Documentação da API
├── package.json
├── serverless.yml            # Definição da infraestrutura (IaC)
└── tsconfig.json
```

---

## 🔧 Setup & Execução Local

O projeto utiliza um ambiente de 3 terminais para simular a nuvem da AWS localmente.

### Pré-requisitos

- Node.js 20.x
- Docker Desktop (precisa estar rodando)
- AWS CLI (Configurado com credenciais 'fake')

_(Para instruções detalhadas de configuração do AWS CLI local, veja o `seeds/README.md`)_

---

### Terminal 1: Iniciar o Banco de Dados (Docker)

Este comando inicia um contêiner do DynamoDB Local na porta 8000. A flag `-sharedDb` é essencial para o funcionamento correto com o AWS CLI. <br>
(Obs: A Flag `-inMemory` para o conteúdo ficar apenas em memoria está ativa)

```bash
docker run -d --name dynamo \
  -p 8000:8000 \
  amazon/dynamodb-local \
  -jar DynamoDBLocal.jar -sharedDb -inMemory
```

### Terminal 2: Iniciar a API (Serverless)

Este comando inicia a API localmente na http://localhost:3000

```bash
serverless offline
```

(ou sls offline se você tiver o Serverless instalado globalmente)

### Terminal 3: Preparar e Semear o Banco (Seed Script)

Uma vez que os Terminais 1 e 2 estejam rodando, use os scripts na pasta /seeds para criar a tabela e popular todos os dados de teste (usuário e produtos) automaticamente.

**No Windows (PowerShell):**

```bash
.\seeds\windows-seed-dynamodb.ps1
```

**No Linux/Mac/Git Bash:**

```bash
# Dê permissão na primeira vez
chmod +x seeds/bash-seed-dynamodb.sh

# Execute o script
./seeds/bash-seed-dynamodb.sh
```

## 🚀 Testes e Qualidade

O projeto é configurado para garantir a qualidade do código.

**Testes Unitários**
Rode a suíte de testes completa (com cobertura) para a camada de serviços:

```bash
npm test
```

**Lint & Formatação**
Verifique erros de lint ou corrija a formatação:

```bash
# Apenas verificar

npm run lint
npm run format:check

# Corrigir automaticamente

npm run lint:fix
npm run format
```

**Gerar Documentação OpenAPI**
Para gerar o arquivo openapi.json:

```bash
npx serverless openapi generate -o openapi.json -f json
```

## 🏛️ Processo de Desenvolvimento (Workflow)

Este projeto foi gerenciado profissionalmente usando o GitHub, Para dar visibilidade a outros desenvolvedores:

- **Issues:** Cada feature ou bug foi rastreado em uma Issue.
- **Commits Semânticos:** Os commits seguem o padrão `feat:`, `fix`:, `docs:`, `test:`, etc., usando `npm run commit` (commitzen).
- **Pull Requests (PRs):** Todo código foi mesclado via PRs, preparando para a automação de CI/CD.

## 📚 Minha Jornada de Aprendizado no Desafio

Este desafio foi uma imersão que me permitiu não só aprender, mas reforçar conceitos fundamentais da stack Serverless da AWS, alinhado à cultura da Stone.

1.  **Serverless & Lambdas:**
    - Aprendi que Lambdas são focadas em _eventos_ e _funções_, não em _servidores_. Que exigem uma arquitetura diferente, onde o estado é gerenciado externamente (ex: DynamoDB).

2.  **Reforço em TypeScript e Testes:**
    - Embora eu já usasse TypeScript e Testes, este projeto foi uma oportunidade de reforço para aplicar tipos de forma mais estrita, criar schemas de validação robustos com Zod e estruturar melhor mocks e testes unitários com 100% de cobertura nos serviços, usando mocks do aws-sdk-client-mock.

3.  **Modelagem NoSQL (DynamoDB Single-Table Design):**
    - A maior mudança de paradigma foi sair da modelagem relacional ou de documentos do MongoDB para o Single-Table Design do DynamoDB.
    - Aprendi a focar em "Padrões de Acesso" antes de escrever qualquer código. Usar chaves compostas (PK/SK) como `USER#email` e `PRODUCTS` foi uma virada de chave para permitir buscas diretas (Query) em vez de varrer a tabela inteira (Scan), o que entendi ser um anti-padrão de performance.

4.  **IAM e CloudWatch:**
    - O ponto de inflexão do projeto foi o deploy. Localmente, tudo funcionava, mas na AWS recebi um `500 Internal Server Error`.
    - O aprendizado real foi mergulhar no CloudWatch e encontrar o log da `AccessDeniedException`. Ali entendi a diferença crucial entre as credenciais do meu usuário (que o CLI usa) e a Role de Execução (que a Lambda assume na nuvem).
    - Resolver isso diretamente no `serverless.yml` conectou os pontos de como a Infraestrutura como Código (IaC) gerencia permissões de forma declarativa.
