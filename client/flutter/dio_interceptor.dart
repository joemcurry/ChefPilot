// Dio interceptor that attaches Authorization header and refreshes on 401
import 'package:dio/dio.dart';
import 'auth_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthService auth;
  AuthInterceptor(this.auth);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (auth.accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${auth.accessToken}';
    }
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    if (res != null && res.statusCode == 401) {
      final refreshed = await auth.refreshAccess();
      if (refreshed && auth.accessToken != null) {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${auth.accessToken}';
        try {
          final clone = await auth.dio.fetch(opts);
          return handler.resolve(clone);
        } catch (e) {
          // ignore
        }
      }
    }
    return handler.next(err);
  }
}
