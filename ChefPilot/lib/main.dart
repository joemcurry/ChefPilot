import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/appowner_dashboard.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'ChefPilot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/appowner': (_) => const AppOwnerDashboard(),
          '/settings': (_) => const SettingsScreen(),
          // navigate to '/profile/<userId>' using Navigator.pushNamed(context, '/profile/USERID')
        },
        onGenerateRoute: (settings) {
          if (settings.name != null && settings.name!.startsWith('/profile/')) {
            final userId = settings.name!.substring('/profile/'.length);
            return MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: userId));
          }
          return null;
        },
        // Inject a Banner-style debug ribbon bottom-left in debug builds that fades after 5s
        builder: (context, child) {
          if (!kDebugMode || child == null)
            return child ?? const SizedBox.shrink();
          return DebugRibbonOverlay(child: child);
        },
      ),
    );
  }
}

/// Overlay that shows a small diagonal "DEBUG" banner in the bottom-left
/// and fades it out after a short delay so it resembles the default banner.
class DebugRibbonOverlay extends StatefulWidget {
  final Widget child;
  const DebugRibbonOverlay({required this.child, super.key});

  @override
  State<DebugRibbonOverlay> createState() => _DebugRibbonOverlayState();
}

class _DebugRibbonOverlayState extends State<DebugRibbonOverlay>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  Timer? _fadeTimer;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    // We'll listen for login (token set) and then start a 3s fade timer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      // If already logged in, schedule fade immediately
      if (auth.token != null) _startFadeTimer();
      // Add listener to detect login/logout
      _authListener = () {
        final a = Provider.of<AuthService>(context, listen: false);
        if (a.token != null) {
          _startFadeTimer();
        } else {
          // show again on logout
          _cancelFadeTimer();
          if (mounted) setState(() => _visible = true);
        }
      };
      auth.addListener(_authListener!);
    });
  }

  void _startFadeTimer() {
    _cancelFadeTimer();
    _fadeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _cancelFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Place a small Banner in the bottom-left corner. The Banner wraps a tiny box
        // so the diagonal ribbon looks like the default debug banner but smaller.
        IgnorePointer(
          ignoring: true,
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Banner(
                  message: 'DEBUG',
                  location: BannerLocation.topEnd,
                  color: Colors.redAccent,
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  child: const SizedBox(width: 80, height: 80),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cancelFadeTimer();
    if (_authListener != null) {
      final auth = Provider.of<AuthService>(context, listen: false);
      auth.removeListener(_authListener!);
    }
    super.dispose();
  }
}
