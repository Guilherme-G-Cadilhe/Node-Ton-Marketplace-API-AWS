import { z } from "zod";

export const listProductsSchema = z.object({
  // 'limit' será uma string "20", então transformamos em número
  limit: z.coerce.number().int().min(1).max(100).default(20),
  // 'cursor' é opcional e é uma string (Base64)
  cursor: z.string().optional(),
});
