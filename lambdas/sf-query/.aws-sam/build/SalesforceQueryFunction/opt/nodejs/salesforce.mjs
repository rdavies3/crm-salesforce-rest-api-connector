import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";
import jwt from "jsonwebtoken";
import { Connection } from "jsforce";
import dotenv from "dotenv";

dotenv.config();

const secretsClient = new SecretsManagerClient({});

const getSalesforceSecrets = async () => {
    if (
        process.env.SF_CLIENT_ID &&
        process.env.SF_USERNAME &&
        process.env.SF_PRIVATE_KEY
    ) {
        console.log("Loading Salesforce secrets from .env");

        return {
            SF_CLIENT_ID: process.env.SF_CLIENT_ID,
            SF_USERNAME: process.env.SF_USERNAME,
            SF_PRIVATE_KEY: process.env.SF_PRIVATE_KEY.replace(/\\n/g, "\n"),
        };
    }

    console.log("Loading Salesforce secrets from AWS Secrets Manager");

    const command = new GetSecretValueCommand({ SecretId: "dev/sandbox" });
    const secretData = await secretsClient.send(command);

    const secrets = JSON.parse(secretData.SecretString);
    secrets.SF_PRIVATE_KEY = secrets.SF_PRIVATE_KEY.replace(/\\n/g, "\n");

    return secrets;
};

export const authenticateSalesforce = async () => {
    try {
        const {
            SF_CLIENT_ID,
            SF_USERNAME,
            SF_PRIVATE_KEY,
        } = await getSalesforceSecrets();

        const loginUrl = process.env.SF_LOGIN_URL || "https://login.salesforce.com";
        const conn = new Connection({ loginUrl });

        const claim = {
            iss: SF_CLIENT_ID,
            sub: SF_USERNAME,
            aud: loginUrl,
            exp: Math.floor(Date.now() / 1000) + 3 * 60,
        };

        const assertion = jwt.sign(claim, SF_PRIVATE_KEY, { algorithm: "RS256" });

        const userInfo = await conn.authorize({
            grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
            assertion,
        });

        console.log("Salesforce authentication successful!");
        console.log("User ID:", userInfo.id);
        console.log("Org ID:", userInfo.organizationId);

        return conn;
    } catch (error) {
        console.error("Salesforce authentication failed:", error);
        throw new Error("Salesforce authentication error: " + error.message);
    }
};