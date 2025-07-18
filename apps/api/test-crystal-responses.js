const https = require('https');

// Test Crystal AI responses with different ovarian cyst questions
async function testCrystalResponses() {
  const MISTRAL_API_KEY = 'dmTNpfhBBWBomYhwbNkb8cu5XMDJjpkp';
  const MISTRAL_URL = 'https://api.mistral.ai/v1/chat/completions';

  const testQuestions = [
    "What are the symptoms of ovarian cysts?",
    "How are ovarian cysts diagnosed?",
    "What types of ovarian cysts are there?",
    "When should I worry about ovarian cyst pain?",
    "Can ovarian cysts cause infertility?"
  ];

  console.log('🧪 Testing Crystal AI responses to ovarian cyst questions...\n');

  for (let i = 0; i < testQuestions.length; i++) {
    const question = testQuestions[i];
    console.log(`📝 Question ${i + 1}: ${question}`);
    
    const requestBody = {
      model: "mistral-large-latest",
      messages: [
        {
          role: "system",
          content: `You are Crystal, a confident and knowledgeable AI health assistant specializing in women's reproductive health, with particular expertise in ovarian cysts and gynecological conditions. 

You provide clear, evidence-based information and practical guidance. You are direct, informative, and supportive without being overly apologetic. You have extensive knowledge about:

OVARIAN CYSTS:
- Types: functional cysts (follicular, corpus luteum), dermoid cysts, cystadenomas, endometriomas
- Symptoms: pelvic pain, bloating, irregular periods, pain during intercourse, urinary urgency
- Risk factors: age, hormonal imbalances, endometriosis, PCOS
- Diagnostic methods: ultrasound, blood tests (CA-125), MRI
- Treatment options: watchful waiting, birth control pills, surgery (laparoscopy/laparotomy)
- When to seek immediate care: severe pain, fever, rapid breathing, dizziness

You provide practical advice while always recommending professional medical consultation for diagnosis and treatment. You are confident in your knowledge and provide clear, actionable information.`
        },
        {
          role: "user",
          content: question
        }
      ],
      max_tokens: 1000,
      temperature: 0.7,
      top_p: 0.9
    };

    try {
      const response = await makeRequest(requestBody);
      console.log(`✅ Response: ${response.substring(0, 200)}...`);
      console.log('---');
    } catch (error) {
      console.log(`❌ Error: ${error.message}`);
      console.log('---');
    }
  }
}

function makeRequest(requestBody) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(requestBody);
    
    const options = {
      hostname: 'api.mistral.ai',
      port: 443,
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Authorization': `Bearer dmTNpfhBBWBomYhwbNkb8cu5XMDJjpkp`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const responseData = JSON.parse(data);
            const content = responseData.choices[0]?.message?.content;
            resolve(content || "No response generated");
          } catch (parseError) {
            reject(new Error(`Error parsing response: ${parseError.message}`));
          }
        } else {
          reject(new Error(`API Error: ${res.statusCode} - ${data}`));
        }
      });
    });

    req.on('error', (error) => {
      reject(new Error(`Request error: ${error.message}`));
    });

    req.write(postData);
    req.end();
  });
}

// Run the test
testCrystalResponses().then(() => {
  console.log('✅ Crystal AI response test completed!');
}).catch(error => {
  console.error('❌ Test failed:', error);
}); 