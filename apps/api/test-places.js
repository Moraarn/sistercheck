const axios = require('axios');

async function testPlacesEndpoint() {
  try {
    console.log('Testing places endpoint...');
    
    // Test the places endpoint
    const response = await axios.get('http://localhost:5000/places?location=-1.2921,36.8219&radius=3000&type=hospital');
    
    console.log('Response status:', response.status);
    console.log('Response data:', JSON.stringify(response.data, null, 2));
    
    if (response.data.status === 'OK') {
      console.log('✅ Places endpoint is working correctly!');
      console.log(`Found ${response.data.results?.length || 0} places`);
    } else {
      console.log('❌ Places endpoint returned an error:', response.data);
    }
  } catch (error) {
    console.error('❌ Error testing places endpoint:', error.message);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', error.response.data);
    }
  }
}

testPlacesEndpoint(); 