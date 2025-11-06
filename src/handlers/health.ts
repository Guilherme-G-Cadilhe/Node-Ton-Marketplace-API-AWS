// Importa os tipos do API Gateway
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

// O 'handler' é a função que a Lambda vai executar
export const check: APIGatewayProxyHandlerV2 = async (event, context) => {
  // Loga o evento (boa prática para debug)
  console.log("Evento recebido:", event);

  // Retorna uma resposta HTTP 200
  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: "API está operacional!",
      timestamp: new Date().toISOString(),
    }),
  };
};
