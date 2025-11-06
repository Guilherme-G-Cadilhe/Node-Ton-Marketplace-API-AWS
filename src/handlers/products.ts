import { APIGatewayEventRequestContextV2, APIGatewayProxyHandlerV2 } from "aws-lambda";
import { ZodError } from "zod";
import { listProductsSchema } from "../schemas/product-schemas";
import { listProducts } from "../services/product-service";

interface AuthorizerLambdaPayload {
  userId: string;
  email: string;
  role: string;
}

// 2. Defina um tipo para o requestContext que *inclui* o que o
// API Gateway vai injetar. Usamos '&' para adicionar propriedades.
type CustomRequestContext = APIGatewayEventRequestContextV2 & {
  authorizer: {
    lambda: AuthorizerLambdaPayload;
  };
};
/**
 * Handler da Lambda para GET /products
 * Esta rota é PROTEGIDA pelo jwtAuthorizer
 */
export const list: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    const requestContext = event.requestContext as CustomRequestContext;
    // O 'context' do autorizador é injetado aqui pelo API Gateway
    const authorizerContext = requestContext.authorizer.lambda;

    console.log(`Usuário ${authorizerContext?.email} (Role: ${authorizerContext?.role}) está acessando /products.`);

    const { limit, cursor } = listProductsSchema.parse(event.queryStringParameters ?? {});

    const result = await listProducts(limit, cursor);

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result),
    };
  } catch (error) {
    if (error instanceof ZodError) {
      return {
        statusCode: 400, // Bad Request
        body: JSON.stringify({
          message: "Erro nos parâmetros da query.",
          errors: error.issues.map((i) => ({ message: i.message, path: i.path })),
        }),
      };
    }

    console.error("Erro inesperado ao listar produtos:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Erro interno do servidor." }),
    };
  }
};
