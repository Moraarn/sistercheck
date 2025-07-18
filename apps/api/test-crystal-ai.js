// Use ESM import for node-fetch
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const BASE_URL = 'http://localhost:5000';

async function testCrystalAI() {
  try {
    // Step 1: Register a test user
    console.log('🔐 Registering test user...');
    const registerResponse = await fetch(`${BASE_URL}/users/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'test@crystal.com',
        password: 'test123456',
        firstName: 'Test',
        lastName: 'User',
        phone: '+1234567890',
        dateOfBirth: '1990-01-01',
        gender: 'female',
        referredBy: 'test'
      })
    });

    if (!registerResponse.ok) {
      const errorData = await registerResponse.text();
      console.log('❌ Registration failed:', errorData);
      return;
    }

    const registerData = await registerResponse.json();
    console.log('✅ User registered successfully');

    // Step 2: Login to get token
    console.log('🔑 Logging in...');
    const loginResponse = await fetch(`${BASE_URL}/users/signin`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'test@crystal.com',
        password: 'test123456'
      })
    });

    if (!loginResponse.ok) {
      const errorData = await loginResponse.text();
      console.log('❌ Login failed:', errorData);
      return;
    }

    const loginData = await loginResponse.json();
    const token = loginData.data.token;
    console.log('✅ Login successful, got token');

    // Step 3: Test Crystal AI endpoint
    console.log('🤖 Testing Crystal AI...');
    const crystalResponse = await fetch(`${BASE_URL}/crystal-ai/talk`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        message: 'Hello Crystal, I have some questions about menstrual health.'
      })
    });

    if (!crystalResponse.ok) {
      const errorData = await crystalResponse.text();
      console.log('❌ Crystal AI failed:', errorData);
      return;
    }

    const crystalData = await crystalResponse.json();
    console.log('✅ Crystal AI response:', JSON.stringify(crystalData, null, 2));

    // Step 4: Test getting sessions
    console.log('📋 Getting chat sessions...');
    const sessionsResponse = await fetch(`${BASE_URL}/crystal-ai/sessions`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!sessionsResponse.ok) {
      const errorData = await sessionsResponse.text();
      console.log('❌ Get sessions failed:', errorData);
      return;
    }

    const sessionsData = await sessionsResponse.json();
    console.log('✅ Sessions:', JSON.stringify(sessionsData, null, 2));

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testCrystalAI(); 