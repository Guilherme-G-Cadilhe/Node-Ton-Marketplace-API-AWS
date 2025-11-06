# ADR 001: Adoção do Design de Tabela Única (Single-Table Design) no DynamoDB

**Status:** Aceito

## Contexto

O desafio exige o uso de um banco de dados, com o DynamoDB sendo um "Plus". A cultura técnica da Stone é fortemente baseada em Serverless e DynamoDB. Precisávamos de um modelo de dados que suportasse múltiplas entidades (Usuários, Produtos, Rate Limit) de forma eficiente.

## Decisão

Adotamos um **Design de Tabela Única (Single-Table Design)**. Todas as entidades são armazenadas na mesma tabela (`ton-marketplace-api-dev`), diferenciadas por um `PK` (Partition Key) e `SK` (Sort Key) compostos.

**Padrões de Acesso (Access Patterns) Implementados:**

- **Login de Usuário:** `PK = USER#<email>` e `SK = METADATA`.
- **Listagem de Produtos:** `PK = PRODUCTS` e `SK = begins_with(PRODUCT#)`.
- **Rate Limit:** `PK = RATE_LIMIT#<userId>` e `SK = BUCKET`.

## Consequências

- **✅ Prós:**
  - **Performance:** A listagem de produtos e o login são consultas de alta performance (Queries O(1)), sem a necessidade de `JOINs` (SQL) ou `Scans` (NoSQL), que são lentos e caros.
  - **Alinhamento Técnico:** Stack principal da Stone (Serverless + DynamoDB).
- **❌ Contras:**
  - **Curva de Aprendizado:** Exige um planejamento inicial dos padrões de acesso, sendo menos flexível para queries ad-hoc do que o SQL.
- **Pivô Técnico:** A listagem de produtos falhou inicialmente (`ValidationException`) porque tentamos usar `begins_with` no `PK`. A arquitetura foi corrigida para usar um `PK` estático (`PRODUCTS`), o que permitiu a query e validou a importância de planejar os _access patterns_.
