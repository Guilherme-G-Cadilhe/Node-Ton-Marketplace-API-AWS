export interface StoredUser {
  PK: string; // Ex: USER#teste@ton.com
  SK: string; // Ex: METADATA
  name: string;
  passwordHash: string;
  role: "seller" | "admin";
}
