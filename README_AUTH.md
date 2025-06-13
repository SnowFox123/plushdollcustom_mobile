# Authentication Service Documentation

This document explains how to use the authentication service in the Flutter mobile application.

## Overview

The authentication service provides a complete authentication system that matches the web application's functionality, including:

- User login with JWT token handling
- Role-based navigation and permissions
- User profile management
- Password reset functionality
- Account verification
- Secure token storage

## Features

### 1. Login System

- Username/password authentication
- JWT token management (access token + refresh token)
- Automatic user profile loading
- Role-based navigation after login

### 2. User Roles

- **Admin**: Full system access
- **Staff**: Staff management features
- **Designer**: Designer-specific features
- **Customer**: Basic user features

### 3. Security Features

- Secure token storage using SharedPreferences
- Automatic token validation
- Session management
- Logout functionality

## File Structure

```
lib/
├── constants/
│   └── api_constants.dart          # API endpoints and constants
├── models/
│   └── user_model.dart             # User data models
├── services/
│   └── auth_service.dart           # Authentication service
├── providers/
│   └── auth_provider.dart          # State management
└── screens/
    ├── login_screen.dart           # Login UI
    └── profile_screen.dart         # Profile UI
```

## Setup Instructions

### 1. Update API Base URL

In `lib/constants/api_constants.dart`, update the base URL:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-actual-api-server.com/api';
  // ... other constants
}
```

### 2. Add Dependencies

Make sure these dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^1.1.0
  shared_preferences: ^2.2.0
```

### 3. Initialize Auth Provider

In your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadStoredData();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: const MyApp(),
    ),
  );
}
```

## Usage Examples

### 1. Login Implementation

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.login(
        usernameController.text,
        passwordController.text,
      );

      if (success) {
        // Navigate based on user role
        final user = authProvider.user;
        switch (user?.role) {
          case UserRole.admin:
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
            break;
          case UserRole.staff:
            Navigator.pushReplacementNamed(context, '/staff-dashboard');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
```

### 2. Check User Authentication

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoggedIn) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  },
)
```

### 3. Role-Based Access Control

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isAdmin) {
      return AdminPanel();
    } else if (authProvider.isStaff) {
      return StaffPanel();
    } else {
      return UserPanel();
    }
  },
)
```

### 4. Get User Information

```dart
final user = authProvider.user;
if (user != null) {
  print('Username: ${user.username}');
  print('Email: ${user.email}');
  print('Role: ${user.role}');
  print('Full Name: ${user.fullName}');
}
```

### 5. Logout

```dart
await authProvider.logout();
Navigator.pushReplacementNamed(context, '/login');
```

## API Methods

### AuthService Methods

#### Login

```dart
static Future<LoginResponse?> login(String username, String password)
```

#### Get Profile

```dart
static Future<User?> getProfile(String token)
```

#### Change Password

```dart
static Future<bool> changePassword(String token, String currentPassword, String newPassword)
```

#### Forgot Password

```dart
static Future<bool> forgotPassword(String email)
```

#### Reset Password

```dart
static Future<bool> resetPassword(String email, String otp, String newPassword)
```

#### Register

```dart
static Future<bool> register({
  required String username,
  required String email,
  required String password,
  String? fullName,
  String? phoneNumber,
})
```

#### Verify Account

```dart
static Future<bool> verifyAccount(String email, String otp)
```

#### Resend OTP

```dart
static Future<bool> resendOtp(String email)
```

## Error Handling

The service includes comprehensive error handling:

- Network errors
- Invalid credentials
- Server errors
- Token expiration
- Validation errors

All errors are thrown as exceptions with descriptive messages in Vietnamese.

## Security Considerations

1. **Token Storage**: Tokens are stored securely using SharedPreferences
2. **Automatic Cleanup**: Invalid tokens are automatically cleared
3. **Session Management**: User sessions are properly managed
4. **Error Handling**: Sensitive information is not exposed in error messages

## Customization

### Adding New Roles

1. Update `UserRole` class in `api_constants.dart`
2. Add role-specific logic in `AuthProvider`
3. Update navigation logic in login screen

### Custom API Endpoints

1. Add new endpoints to `ApiConstants`
2. Create corresponding methods in `AuthService`
3. Update models if needed

### UI Customization

- Modify `login_screen.dart` for custom login UI
- Update `profile_screen.dart` for custom profile display
- Add new screens for additional functionality

## Troubleshooting

### Common Issues

1. **Login Fails**: Check API base URL and network connectivity
2. **Token Expired**: Tokens are automatically cleared on expiration
3. **Role Navigation**: Ensure role constants match server response
4. **Profile Loading**: Check if user data is properly formatted

### Debug Mode

Enable debug logging by adding print statements in the service methods.

## Support

For issues or questions:

1. Check the error messages in the console
2. Verify API endpoint configuration
3. Ensure all dependencies are properly installed
4. Test with the web application to compare behavior
