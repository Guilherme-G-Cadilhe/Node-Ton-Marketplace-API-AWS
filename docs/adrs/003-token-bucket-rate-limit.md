# ADR 003: Rate Limiting com Token Bucket via DynamoDB

**Status:** Aceito

## Contexto

O desafio exige um mecanismo de **rate-limit** para proteger a API contra abuso e garantir estabilidade para todos os usuários.

## Decisão

Implementamos o algoritmo **Token Bucket** (100 tokens/min) com estado persistido no DynamoDB.

**Fluxo:**

1.  O handler `getProducts` (após o autorizador) chama o `consumeToken(userId)`.
2.  O serviço busca um item (`PK = RATE_LIMIT#<userId>`) no DynamoDB.
3.  Ele calcula quantos tokens devem ser recarregados desde a `lastRefill` (baseado em 100 tokens/60s).
4.  Se `tokens >= 1`, ele consome 1 token (atualizando o item no DynamoDB) e permite a requisição.
5.  Se `tokens < 1`, ele lança um erro `RateLimitError`, que o handler converte em um `429 Too Many Requests`.

## Consequências

- **✅ Prós:**
  - **Stateful em Ambiente Stateless:** É uma solução robusta para rate limiting em um ambiente Serverless (Lambda), onde a memória local não é compartilhada.
  - **Distribuído:** Funciona para o mesmo usuário fazendo múltiplas requisições concorrentes que atingem Lambdas diferentes.
  - **Resiliência:** Protege o banco de dados e a API de picos de tráfego, demonstrando excelência e resiliência.
- **❌ Contras:**
  - **Latência e Custo:** Adiciona uma leitura (`GetCommand`) e uma escrita (`UpdateCommand`) ao DynamoDB _em cada_ requisição protegida, aumentando a latência e o custo.
  - **Alternativa (Produção):** Em um cenário de produção em hiperescala, isso poderia ser otimizado movendo o "balde" de tokens para um serviço de cache de alta velocidade, como o AWS ElastiCache (Redis).
