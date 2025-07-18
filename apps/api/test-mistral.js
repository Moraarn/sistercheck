const https = require('https');

// Test Mistral API configuration
async function testMistralAPI() {
  const MISTRAL_API_KEY = 'dmTNpfhBBWBomYhwbNkb8cu5XMDJjpkp';
  const MISTRAL_URL = 'https://api.mistral.ai/v1/chat/completions';

  console.log('🧪 Testing Mistral API configuration...');
  console.log('🧪 API URL:', MISTRAL_URL);
  console.log('🧪 API Key exists:', !!MISTRAL_API_KEY);

  const requestBody = {
    model: "mistral-large-latest",
    messages: [
      {
        role: "system",
        content: "You are Crystal, a compassionate and knowledgeable AI health assistant specializing in women's health."
      },
      {
        role: "user",
        content: "What are the different types of ovarian cysts and how are they treated?"
      }
    ],
    max_tokens: 1000,
    temperature: 0.7,
    top_p: 0.9
  };

  return new Promise((resolve) => {
    const postData = JSON.stringify(requestBody);
    
    const options = {
      hostname: 'api.mistral.ai',
      port: 443,
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MISTRAL_API_KEY}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    console.log('🧪 Sending test request to Mistral AI...');
    
    const req = https.request(options, (res) => {
      console.log('🧪 Response status:', res.statusCode);
      console.log('🧪 Response headers:', res.headers);

      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const responseData = JSON.parse(data);
            console.log('✅ Mistral AI response received successfully!');
            console.log('✅ Generated content:', responseData.choices[0]?.message?.content);
            resolve(true);
          } catch (parseError) {
            console.error('❌ Error parsing response:', parseError);
            resolve(false);
          }
        } else {
          console.error('❌ Mistral AI API Error:', data);
          console.error('❌ Response status:', res.statusCode);
          resolve(false);
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ Error testing Mistral API:', error);
      resolve(false);
    });

    req.write(postData);
    req.end();
  });
}

// Run the test
testMistralAPI().then(success => {
  if (success) {
    console.log('✅ Mistral API test passed!');
  } else {
    console.log('❌ Mistral API test failed!');
  }
}); 