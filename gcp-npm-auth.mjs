import dotenv from 'dotenv';
import { GoogleAuth } from 'google-auth-library';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

// If using ES modules, get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({
  path: join(__dirname, '..', '.env'),
  quiet: true
});

async function getToken() {
  const credentialsJson = process.env.GOOGLE_APPLICATION_CREDENTIALS_JSON;
  
  if (!credentialsJson) {
    throw new Error('GOOGLE_APPLICATION_CREDENTIALS_JSON not set');
  }

  const credentials = JSON.parse(credentialsJson);
  
  const auth = new GoogleAuth({
    credentials,
    scopes: ['https://www.googleapis.com/auth/cloud-platform']
  });

  const client = await auth.getClient();
  const token = await client.getAccessToken();
  
  process.stdout.write(token.token);
}

getToken().catch(console.error);