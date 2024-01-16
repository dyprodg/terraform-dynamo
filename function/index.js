const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

// The name of the DynamoDB table where the names will be saved
const tableName = 'ExampleTable';

// AWS Lambda Handler function
exports.handler = async (event) => {
  // Extract the 'name' parameter from the path
  const name = event.pathParameters.name;

  // Generate a unique Id for the item (e.g., using a UUID library or another method)
  const id = generateUniqueId(); // Replace with your method of generating a unique Id

  // Create parameters for the DynamoDB put operation
  const params = {
    TableName: tableName,
    Item: {
      'Id': id, // Include the 'Id' attribute
      'Name': name,
      'Timestamp': Date.now()
    }
  };

  try {
    // Save the name in the DynamoDB table
    await dynamoDB.put(params).promise();

    // Response on successful save
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Name saved successfully', name: name }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  } catch (error) {
    // Response on error
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error saving the name', error: error.message }),
      headers: {
        'Content-Type': 'application/json'
      }
    };
  }
};

// Helper function to generate a unique Id (this is just a placeholder, implement your own method)
function generateUniqueId() {
  return 'unique-id'; // Replace with actual unique Id generation logic
}
