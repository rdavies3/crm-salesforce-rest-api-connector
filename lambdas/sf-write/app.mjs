import { authenticateSalesforce } from '/opt/salesforce.mjs';

export const handler = async (event) => {
  try {
    // Log the incoming event
    console.log('Received event:', JSON.stringify(event, null, 2));

    let method, sobject, payload;

    let parsedEvent = event;

    // If it's wrapped in API Gateway-style body, parse it
    if (typeof event.body === 'string') {
      try {
        parsedEvent = JSON.parse(event.body);
      } catch (e) {
        console.error("Invalid JSON body received:", e);
        return {
          statusCode: 400,
          body: JSON.stringify({ error: "Malformed JSON in event body" }),
        };
      }
    }

    // Extract method and path parameters from the parsed event
    method = parsedEvent.httpMethod;
    sobject = parsedEvent.pathParameters?.sobject;

    // Log parsed method and sobject
    console.log('Parsed method:', JSON.stringify(method, null, 2));
    console.log('Parsed sobject:', JSON.stringify(sobject, null, 2));

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

    // Extract and parse payload from the parsed event
    try {
      payload = typeof parsedEvent.payload === 'string'
        ? JSON.parse(parsedEvent.payload)
        : parsedEvent.payload;
    } catch (e) {
      console.error("Invalid JSON in payload field:", e);
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Malformed payload JSON" }),
      };
    }
    console.log('Parsed payload:', JSON.stringify(payload, null, 2));

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
