# Contributing to SisterCheck

<div align="center">

**Thank you for your interest in contributing to SisterCheck! 🎉**

We welcome contributions from developers, healthcare professionals, researchers, and anyone passionate about improving women's health through technology.

</div>

## 🤝 How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **🐛 Bug Reports**: Help us identify and fix issues
- **✨ Feature Requests**: Suggest new features and improvements
- **📝 Documentation**: Improve our documentation and guides
- **💻 Code Contributions**: Submit code improvements and new features
- **🧪 Testing**: Help test the application and report issues
- **🌍 Translations**: Help translate the app to more languages
- **📊 Data**: Contribute to our healthcare datasets
- **🔬 Research**: Contribute to our AI model improvements

### Before You Start

1. **Read the Documentation**: Familiarize yourself with the project structure
2. **Check Existing Issues**: Look for existing issues or discussions
3. **Join the Community**: Participate in discussions and ask questions
4. **Set Up Development Environment**: Follow the setup guides for each component

## 🛠️ Development Setup

### Prerequisites

- **Git** - Version control
- **Flutter SDK** (3.8.1+) - For mobile app development
- **Node.js** (18+) - For backend API development
- **Python** (3.13+) - For AI service development
- **MongoDB** - For database (optional for local development)

### Quick Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/sistercheck.git
   cd sistercheck
   ```

2. **Set Up All Components**
   ```bash
   # Set up Flutter app
   flutter pub get
   
   # Set up Node.js backend
   cd sistercheck-api
   npm install
   
   # Set up Python AI service
   cd ../sistercheck-python
   pip install -r requirements.txt
   ```

3. **Start Development Servers**
   ```bash
   # Start backend API (in sistercheck-api directory)
   npm run dev
   
   # Start AI service (in sistercheck-python directory)
   python enhanced_api_server.py
   
   # Start Flutter app (in root directory)
   flutter run
   ```

## 📋 Contribution Guidelines

### Code Style

#### Flutter/Dart
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` for code quality
- Format code with `flutter format`
- Write meaningful commit messages

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test
```

#### Node.js/TypeScript
- Follow [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- Use ESLint and Prettier
- Write JSDoc comments for functions
- Use meaningful variable and function names

```bash
# Format code
npm run format

# Lint code
npm run lint

# Run tests
npm test
```

#### Python
- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide
- Use type hints
- Write docstrings for functions and classes
- Use meaningful variable names

```bash
# Format code
black .

# Lint code
flake8 .

# Run tests
pytest
```

### Git Workflow

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Write clean, well-documented code
   - Add tests for new features
   - Update documentation

3. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

4. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Fill out the PR template

### Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(auth): add biometric authentication
fix(api): resolve user registration issue
docs(readme): update installation instructions
test(ml): add unit tests for prediction model
```

## 🧪 Testing

### Flutter Testing
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Node.js Testing
```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

### Python Testing
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=.

# Run specific test file
pytest test_api_client.py
```

## 📝 Pull Request Process

### Before Submitting

1. **Test Your Changes**
   - Run all tests
   - Test on multiple platforms (if applicable)
   - Check for linting errors

2. **Update Documentation**
   - Update README files if needed
   - Add inline documentation
   - Update API documentation

3. **Check Code Quality**
   - Ensure code follows style guidelines
   - Remove debug code and console logs
   - Optimize performance where possible

### Pull Request Template

When creating a PR, use this template:

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Test addition/update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Cross-platform testing (if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented if necessary)

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Closes #issue_number
```

## 🐛 Bug Reports

### Before Reporting

1. **Check Existing Issues**: Search for similar issues
2. **Reproduce the Bug**: Ensure you can consistently reproduce it
3. **Gather Information**: Collect relevant details

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., Windows 10, macOS 12, Ubuntu 20.04]
- Flutter Version: [e.g., 3.8.1]
- Node.js Version: [e.g., 18.0.0]
- Python Version: [e.g., 3.13.0]

## Additional Information
- Screenshots/videos
- Error logs
- Console output
```

## ✨ Feature Requests

### Before Requesting

1. **Check Existing Features**: Ensure the feature doesn't already exist
2. **Research**: Look for similar features in other healthcare apps
3. **Consider Impact**: Think about how it affects the overall system

### Feature Request Template

```markdown
## Feature Description
Clear description of the requested feature

## Problem Statement
What problem does this feature solve?

## Proposed Solution
How should this feature work?

## Use Cases
- Use case 1
- Use case 2
- Use case 3

## Impact
- User impact
- Technical impact
- Performance impact

## Alternatives Considered
Other approaches that were considered
```

## 🔒 Security

### Security Guidelines

- **Never commit sensitive data**: API keys, passwords, personal information
- **Use environment variables**: Store configuration in `.env` files
- **Validate input**: Always validate and sanitize user input
- **Follow security best practices**: Use HTTPS, implement proper authentication
- **Report security issues**: Use the security issue template

### Security Issue Template

```markdown
## Security Issue Description
Description of the security vulnerability

## Severity
- [ ] Critical
- [ ] High
- [ ] Medium
- [ ] Low

## Steps to Reproduce
Detailed steps to reproduce the vulnerability

## Impact
What could happen if this vulnerability is exploited?

## Suggested Fix
How should this be fixed?

## Additional Information
Any other relevant details
```

## 🌍 Internationalization

### Translation Guidelines

- **Use translation keys**: Don't hardcode text
- **Provide context**: Include context for translators
- **Test translations**: Ensure text fits in UI elements
- **Respect cultural differences**: Consider local healthcare practices

### Adding New Languages

1. **Create translation files**
2. **Add language codes**
3. **Update language selector**
4. **Test with native speakers**

## 📊 Data Contributions

### Healthcare Data Guidelines

- **Anonymize data**: Remove personally identifiable information
- **Follow regulations**: Comply with healthcare data regulations
- **Document sources**: Provide clear documentation of data sources
- **Validate quality**: Ensure data quality and accuracy

### Data Format Standards

- **CSV format**: Use standardized CSV format
- **Column naming**: Use clear, descriptive column names
- **Data types**: Specify data types and units
- **Missing data**: Handle missing data appropriately

## 🔬 Research Contributions

### AI/ML Contributions

- **Model improvements**: Enhance prediction accuracy
- **Feature engineering**: Improve feature selection
- **Algorithm optimization**: Optimize performance
- **Validation studies**: Conduct validation research

### Research Guidelines

- **Document methodology**: Clearly document research methods
- **Provide evidence**: Include validation results
- **Follow standards**: Use healthcare ML best practices
- **Peer review**: Consider peer review for significant changes

## 🏥 Healthcare Professional Contributions

### Clinical Guidelines

- **Evidence-based**: Base recommendations on clinical evidence
- **Guideline compliance**: Follow national healthcare guidelines
- **Safety first**: Prioritize patient safety
- **Professional input**: Consult with healthcare professionals

### Clinical Review Process

- **Expert review**: Have changes reviewed by healthcare experts
- **Validation**: Validate clinical recommendations
- **Documentation**: Document clinical reasoning
- **Continuous improvement**: Regularly update based on new evidence

## 📞 Getting Help

### Communication Channels

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: support@sistercheck.com for sensitive issues
- **Documentation**: Check existing documentation first

### Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) for details.

## 🎉 Recognition

### Contributor Recognition

- **Contributor list**: All contributors are listed in our contributors file
- **Special thanks**: Significant contributors receive special recognition
- **Badges**: Contributors receive badges for different types of contributions
- **Mentorship**: Experienced contributors can mentor new contributors

### Contribution Levels

- **Bronze**: 1-5 contributions
- **Silver**: 6-20 contributions
- **Gold**: 21-50 contributions
- **Platinum**: 50+ contributions

## 📄 License

By contributing to SisterCheck, you agree that your contributions will be licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Thank You

Thank you for contributing to SisterCheck! Your contributions help improve women's health worldwide. Every contribution, no matter how small, makes a difference.

---

<div align="center">

**Together, we can make healthcare better for everyone! 💪**

</div> 