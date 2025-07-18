# SisterCheck Backend API

<div align="center">

![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.6.3-blue.svg)
![Express](https://img.shields.io/badge/Express-4.21.2-lightgrey.svg)
![MongoDB](https://img.shields.io/badge/MongoDB-8.8.1-green.svg)

**RESTful API for women's health management system**

</div>

## 🔧 Overview

The SisterCheck Backend API is a robust, scalable RESTful API built with Node.js, Express, and TypeScript. It provides comprehensive backend services for the SisterCheck women's health platform, including user management, healthcare data processing, and integration with external healthcare systems.

## ✨ Features

### 👥 User Management
- **Authentication & Authorization**: JWT-based secure authentication
- **User Registration**: Patient and healthcare provider registration
- **Profile Management**: User profile creation and updates
- **Role-based Access Control**: Different permissions for patients and providers
- **Password Management**: Secure password hashing and reset functionality

### 🏥 Healthcare Data Management
- **Patient Records**: Comprehensive patient health information storage
- **Medical History**: Historical medical data and treatment records
- **Appointment Scheduling**: Healthcare appointment management
- **Care Plans**: Treatment plan creation and tracking
- **Health Analytics**: Patient data analysis and reporting

### 🔗 Healthcare Integrations
- **FHIR Integration**: Fast Healthcare Interoperability Resources support
- **OpenHIE Connectivity**: Open Health Information Exchange integration
- **DHIS2 Integration**: District Health Information Software 2 connectivity
- **External APIs**: Integration with third-party healthcare services

### 🔐 Security & Compliance
- **Data Encryption**: End-to-end data encryption
- **HIPAA Compliance**: Healthcare data privacy compliance
- **Audit Logging**: Comprehensive activity logging
- **Rate Limiting**: API rate limiting and protection
- **CORS Support**: Cross-origin resource sharing configuration

### 📊 Analytics & Monitoring
- **Health Metrics**: Patient health statistics and trends
- **System Monitoring**: API performance and health monitoring
- **Error Tracking**: Comprehensive error logging and reporting
- **Usage Analytics**: API usage statistics and insights

### 📧 Communication
- **Email Notifications**: Automated email notifications
- **SMS Integration**: Text message notifications
- **Push Notifications**: Mobile push notification support
- **In-app Messaging**: Secure messaging between users

## 🛠️ Technology Stack

### Core Framework
- **Node.js 18+** - JavaScript runtime
- **Express.js 4.21.2** - Web application framework
- **TypeScript 5.6.3** - Type-safe JavaScript

### Database
- **MongoDB 8.8.1** - NoSQL database
- **Mongoose** - MongoDB object modeling

### Authentication & Security
- **JWT (jsonwebtoken)** - JSON Web Token authentication
- **bcrypt** - Password hashing
- **helmet** - Security middleware
- **cors** - Cross-origin resource sharing

### Validation & Sanitization
- **Joi** - Data validation
- **express-validator** - Request validation

### Utilities
- **nodemailer** - Email sending
- **node-cron** - Scheduled tasks
- **axios** - HTTP client
- **chalk** - Terminal styling

## 📁 Project Structure

```
sistercheck-api/
├── src/
│   ├── config/
│   │   ├── db.ts              # Database configuration
│   │   ├── env.ts             # Environment variables
│   │   └── prompts.ts         # AI prompts configuration
│   ├── cron/
│   │   ├── index.ts           # Cron job initialization
│   │   └── notification.cron.ts # Notification scheduling
│   ├── functions/
│   │   └── payment-success-pipeline.ts # Payment processing
│   ├── index.ts               # Application entry point
│   ├── middleware/
│   │   ├── auth/
│   │   │   ├── auth-admin.ts  # Admin authentication
│   │   │   └── auth-user.ts   # User authentication
│   │   ├── common/
│   │   │   ├── error.ts       # Error handling
│   │   │   └── validate.ts    # Request validation
│   │   └── error.ts           # Global error middleware
│   ├── res/
│   │   └── templates/
│   │       ├── analytics.html.ts # Analytics email template
│   │       ├── notification.html.ts # Notification template
│   │       └── survey.html.ts # Survey email template
│   ├── routes/
│   │   ├── admins/            # Admin routes
│   │   ├── care-template/     # Care template routes
│   │   ├── chat/              # Chat functionality
│   │   ├── crystal-ai/        # AI integration routes
│   │   ├── risk-assessment/   # Risk assessment routes
│   │   ├── symptoms/          # Symptoms management
│   │   └── users/             # User management routes
│   ├── types/
│   │   ├── auth.ts            # Authentication types
│   │   ├── global.d.ts        # Global type definitions
│   │   └── global.ts          # Global type exports
│   └── utils/
│       ├── api.bootstrap.ts   # API initialization
│       ├── api.catcher.ts     # Error catching utilities
│       ├── api.errors.ts      # Custom error classes
│       ├── api.features.ts    # API feature utilities
│       ├── api.response.ts    # Response formatting
│       ├── login-token.ts     # Login token utilities
│       └── mailer.ts          # Email utilities
├── package.json               # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
├── nodemon.json              # Development configuration
├── Dockerfile                # Docker configuration
├── docker-compose.yaml       # Docker Compose setup
└── Jenkinsfile               # CI/CD pipeline
```

## 🚀 Getting Started

### Prerequisites

- **Node.js** (18.0.0 or higher)
- **npm** or **yarn** package manager
- **MongoDB** (4.4 or higher)
- **Git**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/sistercheck.git
   cd sistercheck-api
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Environment setup**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Edit environment variables
   nano .env
   ```

4. **Database setup**
   ```bash
   # Start MongoDB (if using local installation)
   mongod
   
   # Or use Docker
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   ```

5. **Start development server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

### Environment Configuration

Create a `.env` file with the following variables:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/sistercheck
MONGODB_URI_PROD=mongodb://your-production-db-url

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=30d

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
EMAIL_FROM=SisterCheck <noreply@sistercheck.com>

# AI Service Configuration
AI_SERVICE_URL=http://localhost:5001
AI_SERVICE_API_KEY=your-ai-service-key

# External APIs
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
FHIR_SERVER_URL=http://hapi.fhir.org/baseR4
OPENHIE_URL=http://localhost:8080/openhim-core
DHIS2_URL=http://localhost:8080/dhis

# Security
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX=100

# Logging
LOG_LEVEL=debug
LOG_FILE=logs/app.log
```

## 📚 API Documentation

### Authentication Endpoints

#### POST `/api/auth/register`
Register a new user (patient or provider)

```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "role": "patient",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+254700000000"
}
```

#### POST `/api/auth/login`
Authenticate user and get JWT token

```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

#### POST `/api/auth/refresh`
Refresh JWT token

```json
{
  "refreshToken": "your-refresh-token"
}
```

### User Management Endpoints

#### GET `/api/users/profile`
Get current user profile

#### PUT `/api/users/profile`
Update user profile

#### GET `/api/users/:id`
Get user by ID (admin only)

#### GET `/api/users`
Get all users (admin only)

### Healthcare Data Endpoints

#### POST `/api/care-template`
Create care template

#### GET `/api/care-template/:id`
Get care template by ID

#### PUT `/api/care-template/:id`
Update care template

#### DELETE `/api/care-template/:id`
Delete care template

### AI Integration Endpoints

#### POST `/api/crystal-ai/predict`
Get AI prediction for patient data

#### POST `/api/risk-assessment`
Assess patient risk level

#### GET `/api/crystal-ai/history`
Get AI prediction history

### Admin Endpoints

#### GET `/api/admins/dashboard`
Get admin dashboard data

#### GET `/api/admins/analytics`
Get system analytics

#### POST `/api/admins/broadcast`
Send broadcast message to users

## 🔧 Development

### Code Style

We use ESLint and Prettier for code formatting:

```bash
# Install ESLint and Prettier
npm install -g eslint prettier

# Format code
npm run format

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix
```

### Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- --grep "user registration"
```

### Database Migrations

```bash
# Create migration
npm run migration:create -- --name add-user-roles

# Run migrations
npm run migration:run

# Rollback migration
npm run migration:rollback
```

### API Testing

We use REST Client for API testing. Test files are in the `routes/` directories:

```bash
# Test user registration
http POST http://localhost:3000/api/auth/register \
  email=test@example.com \
  password=password123 \
  role=patient

# Test login
http POST http://localhost:3000/api/auth/login \
  email=test@example.com \
  password=password123
```

## 🔐 Security Features

### Authentication & Authorization
- **JWT Tokens**: Secure token-based authentication
- **Refresh Tokens**: Automatic token renewal
- **Role-based Access**: Different permissions for different user types
- **Password Security**: bcrypt hashing with configurable rounds

### Data Protection
- **Input Validation**: Comprehensive request validation
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Input sanitization
- **CORS Configuration**: Secure cross-origin requests

### Rate Limiting
- **API Rate Limiting**: Prevent abuse and DDoS attacks
- **IP-based Limiting**: Track requests by IP address
- **User-based Limiting**: Track requests by user ID

## 📊 Monitoring & Logging

### Logging Configuration
```typescript
// Log levels: error, warn, info, debug
const logLevel = process.env.LOG_LEVEL || 'info';

// Log formats
const logFormat = {
  timestamp: true,
  level: true,
  message: true,
  metadata: true
};
```

### Health Checks
```bash
# Health check endpoint
GET /api/health

# Response
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "uptime": 3600,
  "database": "connected",
  "memory": {
    "used": "150MB",
    "total": "512MB"
  }
}
```

## 🚀 Deployment

### Production Setup

1. **Environment Configuration**
   ```bash
   # Set production environment
   export NODE_ENV=production
   
   # Set production database
   export MONGODB_URI=mongodb://your-production-db
   ```

2. **Build the application**
   ```bash
   npm run build
   ```

3. **Start production server**
   ```bash
   npm start
   ```

### Docker Deployment

```bash
# Build Docker image
docker build -t sistercheck-api .

# Run container
docker run -d \
  --name sistercheck-api \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e MONGODB_URI=mongodb://your-db \
  sistercheck-api
```

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/sistercheck
    depends_on:
      - mongo
  
  mongo:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

## 🔄 CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy API

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
      - run: npm run build
      - run: npm run deploy
```

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'docker build -t sistercheck-api .'
                sh 'docker push your-registry/sistercheck-api'
            }
        }
    }
}
```

## 📈 Performance Optimization

### Caching Strategy
- **Redis Caching**: Frequently accessed data
- **Response Caching**: API response caching
- **Database Query Optimization**: Indexed queries

### Database Optimization
```javascript
// Create indexes for better performance
db.users.createIndex({ "email": 1 }, { unique: true });
db.patients.createIndex({ "userId": 1 });
db.careTemplates.createIndex({ "patientId": 1, "createdAt": -1 });
```

### API Optimization
- **Pagination**: Large dataset pagination
- **Compression**: Response compression
- **Connection Pooling**: Database connection pooling

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Issues**
   ```bash
   # Check MongoDB status
   sudo systemctl status mongod
   
   # Restart MongoDB
   sudo systemctl restart mongod
   ```

2. **Port Already in Use**
   ```bash
   # Find process using port 3000
   lsof -i :3000
   
   # Kill process
   kill -9 <PID>
   ```

3. **JWT Token Issues**
   ```bash
   # Check JWT secret
   echo $JWT_SECRET
   
   # Regenerate JWT secret
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```

### Debug Mode

Enable debug mode for detailed logging:

```bash
# Set debug environment
export DEBUG=app:*
export LOG_LEVEL=debug

# Start server in debug mode
npm run dev:debug
```

## 📚 API Documentation

For detailed API documentation, see:
- [API Reference](../docs/api-reference.md)
- [Integration Guide](../INTEGRATION_GUIDE.md)
- [Backend Integration](../BACKEND_INTEGRATION.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Development Guidelines

- Follow TypeScript best practices
- Write unit tests for new features
- Update API documentation
- Follow the existing code style

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🆘 Support

- **Documentation**: [API Documentation](../docs/api-docs.md)
- **Issues**: [GitHub Issues](https://github.com/your-username/sistercheck/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/sistercheck/discussions)
- **Email**: support@sistercheck.com

---

<div align="center">

**Built with ❤️ for Women's Health**

[Privacy Policy](../docs/privacy.md) | [Terms of Service](../docs/terms.md)

</div> 