import { authenticateSalesforce } from '/opt/salesforce.mjs';

export const handler = async (event) => {
  try {
    const method = event.httpMethod;
    const sobject = event.pathParameters?.sobject;

    if (!method) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Missing HTTP method' }),
      };
    }

    if (!sobject) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Missing sobject type in path' }),
      };
    }

    const payload = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;

    const conn = await authenticateSalesforce();
    let result;

    if (method === 'POST') {
      console.log(`Creating ${sobject}...`);
      result = await conn.sobject(sobject).create(payload);
    } else if (method === 'PATCH') {
      if (!payload.Id) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: 'PATCH requires "Id" in payload' }),
        };
      }
      console.log(`Updating ${sobject} with Id ${payload.Id}...`);
      result = await conn.sobject(sobject).update(payload);
    } else {
      return {
        statusCode: 405,
        body: JSON.stringify({ error: `Method ${method} not allowed` }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify(result),
    };
  } catch (err) {
    console.error('Salesforce write failed:', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
