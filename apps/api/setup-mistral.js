const fs = require('fs');
const path = require('path');

// Mistral API configuration
const MISTRAL_API_KEY = 'dmTNpfhBBWBomYhwbNkb8cu5XMDJjpkp';
const MISTRAL_URL = 'https://api.mistral.ai/v1/chat/completions';

console.log('🔧 Setting up Mistral API configuration...');

// Create or update .env file
const envPath = path.join(__dirname, '.env');
let envContent = '';

// Check if .env file exists
if (fs.existsSync(envPath)) {
  envContent = fs.readFileSync(envPath, 'utf8');
  console.log('📁 Found existing .env file');
} else {
  console.log('📁 Creating new .env file');
}

// Add or update Mistral configuration
const mistralConfig = `# Mistral AI Configuration
MISTRAL_API_KEY=${MISTRAL_API_KEY}
MISTRAL_URL=${MISTRAL_URL}

`;

// Check if Mistral config already exists
if (envContent.includes('MISTRAL_API_KEY')) {
  console.log('✅ Mistral API configuration already exists in .env file');
} else {
  // Add Mistral config to the beginning of the file
  envContent = mistralConfig + envContent;
  fs.writeFileSync(envPath, envContent);
  console.log('✅ Added Mistral API configuration to .env file');
}

console.log('🔧 Mistral API Setup Complete!');
console.log('🔧 API Key:', MISTRAL_API_KEY ? 'Configured' : 'Missing');
console.log('🔧 API URL:', MISTRAL_URL);

// Test the configuration
console.log('\n🧪 Testing configuration...');
require('./test-mistral.js'); 