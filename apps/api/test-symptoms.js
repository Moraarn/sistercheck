const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

const BASE_URL = 'http://localhost:5000';

async function testSymptoms() {
  try {
    // Step 1: Register a test user
    console.log('🔐 Registering test user...');
    const registerResponse = await fetch(`${BASE_URL}/users/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'symptoms-test-2@example.com',
        password: 'test123456',
        firstName: 'Symptoms',
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
        email: 'symptoms-test-2@example.com',
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

    // Step 3: Create a symptom entry
    console.log('📝 Creating symptom entry...');
    const createResponse = await fetch(`${BASE_URL}/symptoms`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        symptoms: {
          bloating: true,
          pelvicPain: false,
          irregularPeriods: true,
          heavyBleeding: false,
          fatigue: true,
          moodSwings: true,
          breastTenderness: false,
          backPain: true,
          nausea: false,
          weightGain: true,
          otherSymptoms: "Mild headaches and dizziness"
        },
        severity: "Moderate",
        duration: "3 days",
        notes: "Symptoms started after my period ended. Feeling better today."
      })
    });

    if (!createResponse.ok) {
      const errorData = await createResponse.text();
      console.log('❌ Create symptom failed:', errorData);
      return;
    }

    const createData = await createResponse.json();
    console.log('✅ Symptom entry created successfully:', JSON.stringify(createData, null, 2));

    const symptomId = createData.data.symptom._id;

    // Step 4: Get latest symptom entry
    console.log('📋 Getting latest symptom entry...');
    const latestResponse = await fetch(`${BASE_URL}/symptoms/latest`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!latestResponse.ok) {
      const errorData = await latestResponse.text();
      console.log('❌ Get latest symptom failed:', errorData);
      return;
    }

    const latestData = await latestResponse.json();
    console.log('✅ Latest symptom entry:', JSON.stringify(latestData, null, 2));

    // Step 5: Get all symptoms
    console.log('📊 Getting all symptoms...');
    const allResponse = await fetch(`${BASE_URL}/symptoms`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!allResponse.ok) {
      const errorData = await allResponse.text();
      console.log('❌ Get all symptoms failed:', errorData);
      return;
    }

    const allData = await allResponse.json();
    console.log('✅ All symptoms:', JSON.stringify(allData, null, 2));

    // Step 6: Get symptom statistics
    console.log('📈 Getting symptom statistics...');
    const statsResponse = await fetch(`${BASE_URL}/symptoms/stats`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!statsResponse.ok) {
      const errorData = await statsResponse.text();
      console.log('❌ Get stats failed:', errorData);
      return;
    }

    const statsData = await statsResponse.json();
    console.log('✅ Symptom statistics:', JSON.stringify(statsData, null, 2));

    // Step 7: Update the symptom entry
    console.log('✏️ Updating symptom entry...');
    const updateResponse = await fetch(`${BASE_URL}/symptoms/${symptomId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        severity: "Mild",
        notes: "Symptoms have improved significantly. Feeling much better now."
      })
    });

    if (!updateResponse.ok) {
      const errorData = await updateResponse.text();
      console.log('❌ Update symptom failed:', errorData);
      return;
    }

    const updateData = await updateResponse.json();
    console.log('✅ Symptom updated successfully:', JSON.stringify(updateData, null, 2));

    // Step 8: Get symptoms by severity
    console.log('🔍 Getting symptoms by severity...');
    const severityResponse = await fetch(`${BASE_URL}/symptoms/severity/Mild`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!severityResponse.ok) {
      const errorData = await severityResponse.text();
      console.log('❌ Get symptoms by severity failed:', errorData);
      return;
    }

    const severityData = await severityResponse.json();
    console.log('✅ Symptoms by severity:', JSON.stringify(severityData, null, 2));

    // Step 9: Get recent symptoms
    console.log('📅 Getting recent symptoms...');
    const recentResponse = await fetch(`${BASE_URL}/symptoms/recent`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!recentResponse.ok) {
      const errorData = await recentResponse.text();
      console.log('❌ Get recent symptoms failed:', errorData);
      return;
    }

    const recentData = await recentResponse.json();
    console.log('✅ Recent symptoms:', JSON.stringify(recentData, null, 2));

    // Step 10: Delete the symptom entry
    console.log('🗑️ Deleting symptom entry...');
    const deleteResponse = await fetch(`${BASE_URL}/symptoms/${symptomId}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!deleteResponse.ok) {
      const errorData = await deleteResponse.text();
      console.log('❌ Delete symptom failed:', errorData);
      return;
    }

    const deleteData = await deleteResponse.json();
    console.log('✅ Symptom deleted successfully:', JSON.stringify(deleteData, null, 2));

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testSymptoms(); 