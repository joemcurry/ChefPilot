# Flutter client quickstart

This directory contains a minimal auth service and a Dio interceptor to work with
the ChefPilot-API's access + refresh token flow.

## Dependencies (pubspec.yaml)

- dio: ^5.0.0
- flutter_secure_storage: ^8.0.0
- jwt_decoder: ^2.0.1

## Files

`auth_service.dart` - simple auth service that stores refresh token securely and
keeps access token in-memory

- `dio_interceptor.dart` - Dio interceptor that attaches Authorization header and
	refreshes token on 401

- `integration_test.dart` - example Dart test flow that demonstrates login ->
	create temp-log -> refresh flow

## Usage

1. Add the dependencies to your Flutter project's `pubspec.yaml`.
2. Copy `auth_service.dart` and `dio_interceptor.dart` into your project, wire
	the interceptor into your Dio client, and call `AuthService.login(...)`.
3. Use `AuthService` methods to manage login, logout, and refresh.

## Security notes

- Store refresh tokens in secure storage (Keychain/Keystore) and never write them to logs.
- This example is minimal for integration testing and requires production hardening before release.
