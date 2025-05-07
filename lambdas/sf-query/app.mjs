import { authenticateSalesforce } from '/opt/salesforce.mjs';

export const handler = async (event) => {
  try {
    // Log the incoming event
    console.log('Received event:', JSON.stringify(event, null, 2));

    let query = event.query;

    // Log the extracted query
    console.log('Extracted query:', query);

    if (!query && event.body) {
      try {
        const parsed = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
        query = parsed.query;
        // Log the parsed query
        console.log('Parsed query:', query);
      } catch (e) {
        console.error("Invalid JSON body:", e);
      }
    }
    const conn = await authenticateSalesforce();

    // Log before making the request
    console.log('Running SOQL query...');

    const result = await conn.query(query);

    // Log result summary
    console.log(`Query successful. Returned ${result.records.length} records.`);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(result.records),
    };
  } catch (err) {
    console.error('Salesforce query failed:', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
