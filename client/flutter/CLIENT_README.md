# Client wiring quick steps

1. Add dependencies to `pubspec.yaml`:

   dependencies:
     dio: ^5.0.0
     flutter_secure_storage: ^8.0.0
     jwt_decoder: ^2.0.1

1. Copy `auth_service.dart` and `dio_interceptor.dart` into your Flutter project.

1. Initialize Dio and register interceptor:

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'http://127.0.0.1:3000',
  ),
);
final auth = AuthService(dio);
dio.interceptors.add(AuthInterceptor(auth));
```

1. Login and use API:

```dart
await auth.login('admin', 'password123');
final res = await dio.post(
  '/api/temperature-logs',
  data: {...},
);
```

1. Logout: `await auth.logout();`

## Notes

- This is a minimal example intended for integration and development use. In production, ensure secure handling, token rotation, and better error handling.
 - This is a minimal example intended for integration and development use. In
   production, ensure secure handling, token rotation, and better error handling.
