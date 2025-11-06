# ADR 002: Autenticação via Custom Authorizer (JWT)

**Status:** Aceito

## Contexto

O desafio exige autenticação JWT e uma rota protegida. Precisávamos de um mecanismo para validar o token JWT em rotas privadas (como `GET /products`) de forma segura e escalável.

## Decisão

Implementamos um **Custom Authorizer** (`jwtAuthorizer`) do tipo `request` no API Gateway (HTTP API v2).

**Fluxo:**

1.  O `POST /auth/login` gera um token JWT assinado.
2.  O cliente envia este token no header `Authorization: Bearer <token>` para `GET /products`.
3.  O API Gateway **intercepta** a chamada e invoca a Lambda `jwtAuthorizer`.
4.  A `jwtAuthorizer` valida o token (assinatura e expiração).
5.  Se válido, ela retorna uma política `Allow` e injeta o `context` (com `userId`, `email`) na requisição, que é então repassada para a Lambda `getProducts`.
6.  Se inválido, ela lança um erro, e o API Gateway retorna `401 Unauthorized`.

## Consequências

- **✅ Prós:**
  - **Separação de Responsabilidades (SOLID):** Nossas funções de negócio (ex: `getProducts`) não precisam saber como validar um token. Elas apenas consomem o `context` que o autorizador já validou.
  - **Segurança:** Centraliza a lógica de autenticação em um único local.
  - **Performance:** O API Gateway pode fazer cache do resultado do autorizador, reduzindo a latência em chamadas subsequentes.
- **❌ Contras:**
  - **Overhead de Latência:** Adiciona uma invocação de Lambda (Cold Start + execução) na primeira requisição de um usuário.
