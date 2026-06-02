import dotenv from "dotenv";
dotenv.config();

export const env = {
  JWT_SECRET: process.env.JWT_SECRET!,
  B2_BUCKET: process.env.B2_BUCKET_NAME!,
  CDN: process.env.CDN_BASE_URL!,
};