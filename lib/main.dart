import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:flutter_supabase/pages/home_page.dart';
import 'package:flutter_supabase/pages/start_page.dart';
import "package:supabase_flutter/supabase_flutter.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env
  await dotenv.load();
  // Initialize Supabase
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_KEY'] ?? '';
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    debugPrint('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colorSchemeLight = ColorScheme.fromSeed(seedColor: Colors.teal);
    final colorSchemeDark = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    );

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Supabase',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorSchemeLight,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: const Color(0xFF24A1DE),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            // No rounded shape for header
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSchemeLight.primary,
              foregroundColor: colorSchemeLight.onPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorSchemeLight.primary,
              side: BorderSide(color: colorSchemeLight.primary, width: 1.5),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: colorSchemeDark,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: const Color(0xFF24A1DE),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black54,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            // No rounded shape for header
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSchemeDark.primary,
              foregroundColor: colorSchemeDark.onPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorSchemeDark.primary,
              side: BorderSide(color: colorSchemeDark.primary, width: 1.5),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AuthPage());
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  User? _user;

  @override
  void initState() {
    _getAuth();
    super.initState();
  }

  // To get current user : supabase.auth.currentUser

  Future<void> _getAuth() async {
    setState(() {
      _user = supabase.auth.currentUser;
    });
    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        _user = event.session?.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const StartPage() : HomePage();
  }
}
