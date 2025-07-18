# Crystal AI Setup Guide

This guide will help you set up Crystal AI with the Mistral API for your SisterCheck application.

## 🚀 Quick Setup

### 1. Configure Environment Variables

The Mistral API credentials have been configured in the code. To set up the environment:

```bash
# Navigate to the API directory
cd sistercheck-api

# Run the setup script
node setup-mistral.js
```

### 2. Test the Configuration

```bash
# Test the Mistral API connection
node test-mistral.js
```

### 3. Start the Server

```bash
# Install dependencies (if not already done)
npm install

# Start the development server
npm run dev
```

## 🔧 Configuration Details

### Environment Variables

The following environment variables are used:

```env
MISTRAL_API_KEY=dmTNpfhBBWBomYhwbNkb8cu5XMDJjpkp
MISTRAL_URL=https://api.mistral.ai/v1/chat/completions
```

### API Endpoints

- **POST** `/crystal-ai/talk` - Send a message to Crystal AI
- **GET** `/crystal-ai/sessions` - Get user's chat sessions
- **GET** `/crystal-ai/sessions/:sessionId` - Get session with messages
- **DELETE** `/crystal-ai/sessions/:sessionId` - Delete a session

## 🤖 Crystal AI Features

### System Prompt
Crystal AI is configured with a specialized system prompt for women's health:

```
You are Crystal, a compassionate and knowledgeable AI health assistant specializing in women's health. You provide supportive, evidence-based information about reproductive health, menstrual cycles, ovarian cysts, and general wellness. Always be empathetic, professional, and encourage users to consult healthcare providers for serious concerns. Keep responses informative but not overwhelming.
```

### Capabilities
- **Health Information**: Provides evidence-based information about women's health
- **Symptom Guidance**: Helps users understand symptoms and when to seek medical care
- **Educational Content**: Explains medical concepts in accessible language
- **Conversation Memory**: Maintains context across conversation sessions
- **Professional Tone**: Always encourages consulting healthcare providers for serious concerns

## 🧪 Testing

### Test the API

1. **Start the server**:
   ```bash
   npm run dev
   ```

2. **Test with curl**:
   ```bash
   curl -X POST http://localhost:5000/crystal-ai/talk \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -d '{
       "message": "Hello Crystal, I have a question about ovarian cysts. Can you help me?"
     }'
   ```

3. **Test from Flutter app**:
   - Navigate to the Crystal AI chat screen
   - Send a test message
   - Check the console logs for detailed debugging information

### Debug Information

The Crystal AI service includes comprehensive logging:

- **API Configuration**: Logs API key and URL status
- **Request Details**: Shows request body and headers
- **Response Status**: Logs response status and headers
- **Error Handling**: Detailed error messages for troubleshooting

## 🔍 Troubleshooting

### Common Issues

1. **API Key Not Found**
   - Check that the environment variables are set correctly
   - Verify the `.env` file exists and contains the API key

2. **Network Errors**
   - Check internet connectivity
   - Verify the Mistral API URL is accessible

3. **Authentication Errors**
   - Ensure the JWT token is valid
   - Check that the user is properly authenticated

4. **Rate Limiting**
   - Mistral API has rate limits
   - Check the response headers for rate limit information

### Debug Steps

1. **Check Environment Variables**:
   ```bash
   node -e "console.log('MISTRAL_API_KEY:', process.env.MISTRAL_API_KEY)"
   ```

2. **Test API Connection**:
   ```bash
   node test-mistral.js
   ```

3. **Check Server Logs**:
   - Look for Crystal AI logs in the server console
   - Check for any error messages

4. **Verify Flutter Integration**:
   - Check the Flutter app logs
   - Verify the network requests are being sent

## 📱 Flutter Integration

The Flutter app is already configured to use the Crystal AI service. The integration includes:

- **CrystalAIService**: Handles communication with the backend
- **Chat Interface**: User-friendly chat UI
- **Session Management**: Maintains conversation history
- **Error Handling**: Graceful error handling and user feedback

## 🎯 Next Steps

1. **Test the setup** using the provided test scripts
2. **Start the server** and verify it's running correctly
3. **Test from the Flutter app** by navigating to the Crystal AI chat
4. **Monitor the logs** for any issues or errors
5. **Customize the system prompt** if needed for your specific use case

## 📞 Support

If you encounter any issues:

1. Check the console logs for detailed error messages
2. Verify the environment variables are set correctly
3. Test the API connection using the provided test scripts
4. Check the network connectivity and firewall settings

The Crystal AI is now ready to provide compassionate, evidence-based health information to your users! 🌟 