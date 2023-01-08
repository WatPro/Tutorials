exports = async function(payload, response) {
  // Convert the request body from BSON to a JSON object and then pull out relevant fields
  const { someField } = JSON.parse(payload.body.text());
  // If the request is missing required fields or something else is wrong, respond with an error
  if (!someField) {
    response.setStatusCode(400)
    response.setBody(`Could not find "someField" in the endpoint request body.`);
  }
  // Execute application logic, such as working with MongoDB
  const cluster = context.services.get('mongodb-atlas');
  const requests = cluster.db("demo").collection("requests");
  try {
    const { insertedId } = await requests.insertOne({ someField });
    // Respond with an affirmative result
    response.setStatusCode(200)
    response.setBody(`Successfully created a document for the request with _id: ${insertedId}.`);
  } catch (err) {
    // If the insert fails for some reason, respond with an error
    response.setStatusCode(500)
    response.setBody(`Failed to create a document for the request. ${err}`)
  }
}
