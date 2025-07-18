const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const BASE_URL = 'http://localhost:5000';

async function testRiskAssessment() {
  try {
    // Step 1: Register a test user
    console.log('🔐 Registering test user...');
    const registerResponse = await fetch(`${BASE_URL}/users/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'risk-test@example.com',
        password: 'test123456',
        firstName: 'Risk',
        lastName: 'Tester',
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
        email: 'risk-test@example.com',
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

    // Step 3: Submit a risk assessment
    console.log('📊 Submitting risk assessment...');
    const assessmentResponse = await fetch(`${BASE_URL}/risk-assessment`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        answers: {
          bloating: true,
          pelvicPain: false,
          irregularPeriods: true,
          mood: 'stressed',
          exercise: 'light'
        }
      })
    });

    if (!assessmentResponse.ok) {
      const errorData = await assessmentResponse.text();
      console.log('❌ Risk assessment failed:', errorData);
      return;
    }

    const assessmentData = await assessmentResponse.json();
    console.log('✅ Risk assessment submitted successfully:', JSON.stringify(assessmentData, null, 2));

    // Step 4: Get latest assessment
    console.log('📋 Getting latest assessment...');
    const latestResponse = await fetch(`${BASE_URL}/risk-assessment/latest`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!latestResponse.ok) {
      const errorData = await latestResponse.text();
      console.log('❌ Get latest assessment failed:', errorData);
      return;
    }

    const latestData = await latestResponse.json();
    console.log('✅ Latest assessment:', JSON.stringify(latestData, null, 2));

    // Step 5: Get all assessments
    console.log('📊 Getting all assessments...');
    const allResponse = await fetch(`${BASE_URL}/risk-assessment`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!allResponse.ok) {
      const errorData = await allResponse.text();
      console.log('❌ Get all assessments failed:', errorData);
      return;
    }

    const allData = await allResponse.json();
    console.log('✅ All assessments:', JSON.stringify(allData, null, 2));

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testRiskAssessment(); 