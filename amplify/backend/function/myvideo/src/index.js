const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const tableName = process.env.STORAGE_VIDEO_NAME;

exports.handler = async (event) => {
  try {
    if (event.httpMethod !== 'POST') {
      return {
        statusCode: 405,
        body: JSON.stringify({ message: 'Method Not Allowed' }),
      };
    }

    const body = JSON.parse(event.body);

    const params = {
     TableName: tableName,
      Item: {
        n: body.id, // partition key
        title: body.title,
        uploaderId: body.uploaderId,
        s3Key: body.s3Key,
        pic: body.pic || '',
        sd: body.sd,
        hd: body.hd,
        createdAt: body.createdAt,
      },
    };

    await docClient.put(params).promise();

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*',
      },
      body: JSON.stringify({ message: 'Video added successfully!' }),
    };
  } catch (err) {
    console.error('❌ Lambda error:', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Internal Server Error', error: err.message }),
    };
  }
};
