# Backend Integration Guide

This document explains how the CodeHer Flutter app is connected to the backend API for user authentication and registration.

## Overview

The Flutter app is now fully integrated with the Node.js/Express backend API running on `http://localhost:5000`. The integration includes:

- User registration (User, Peer Sister, Nurse roles)
- User login
- Password reset functionality
- Authentication state management

## Backend API Endpoints

### User Registration
- **POST** `/users/signup`
- **Body**: 
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string",
    "name": "string",
    "age": "number",
    "language": "string",
    "location": "string",
    "role": "user|peer_sister|nurse",
    "referralCode": "string (optional)"
  }
  ```

### User Login
- **POST** `/users/signin`
- **Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```

### Password Reset
- **POST** `/users/request-password-reset`
- **Body**:
  ```json
  {
    "email": "string"
  }
  ```

- **POST** `/users/reset-password`
- **Body**:
  ```json
  {
    "token": "string",
    "newPassword": "string"
  }
  ```

## Flutter App Integration

### Authentication Service
The app uses `AuthService` (`lib/plugins/utils/auth_service.dart`) to handle all authentication operations:

- `registerUser()` - Register new users
- `loginUser()` - Login existing users
- `logout()` - Logout users
- `requestPasswordReset()` - Request password reset
- `resetPassword()` - Reset password with token

### Network Configuration
- **Base URL**: `http://localhost:5000` (configured in `lib/plugins/network_constant.dart`)
- **Network Provider**: Handles HTTP requests with caching and error handling
- **Authentication**: Uses cookie-based authentication from backend

### State Management
- **Riverpod**: Used for state management
- **AppNotifier**: Manages authentication state, user data, and app settings
- **SharedPreferences**: Stores authentication tokens and user data locally

## Testing the Integration

### 1. Start the Backend
```bash
cd sistercheck-api
npm install
npm run dev
```

The backend should start on `http://localhost:5000`

### 2. Test Backend Endpoints
```bash
# Test registration
curl -X POST http://localhost:5000/users/signup \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User",
    "age": 25,
    "language": "English",
    "location": "Nairobi",
    "role": "user"
  }'

# Test login
curl -X POST http://localhost:5000/users/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. Test Flutter App
1. Run the Flutter app: `flutter run`
2. Navigate to the signup screen
3. Choose a role (User, Peer Sister, or Nurse)
4. Fill in the registration form
5. Submit and verify successful registration
6. Try logging in with the created account

## User Roles

### User
- Basic health resources access
- Risk assessment quizzes
- Profile management

### Peer Sister
- Support and mentor other women
- Community engagement
- Peer support features

### Nurse
- Professional medical guidance
- Clinical support
- Medical expertise features

## Error Handling

The app includes comprehensive error handling:

- Network connectivity issues
- Invalid credentials
- Server errors
- Validation errors
- User-friendly error messages

## Security Features

- Password hashing (bcrypt)
- JWT token authentication
- Cookie-based sessions
- Input validation
- SQL injection prevention

## Future Enhancements

- Google OAuth integration
- Push notifications
- Real-time chat
- File uploads
- Offline support
- Advanced caching

## Troubleshooting

### Common Issues

1. **Backend not running**
   - Ensure the backend is started on port 5000
   - Check for any error messages in the backend console

2. **Network connection issues**
   - Verify the base URL in `network_constant.dart`
   - Check if the device/emulator can reach localhost

3. **Authentication issues**
   - Clear app data and try again
   - Check backend logs for authentication errors

4. **Form validation errors**
   - Ensure all required fields are filled
   - Check email format and password strength

### Debug Mode

Enable debug logging by checking the console output for:
- Network request logs
- Authentication state changes
- Error messages

## Support

For issues or questions about the backend integration, check:
1. Backend logs in the terminal
2. Flutter app console output
3. Network tab in browser dev tools
4. This documentation 