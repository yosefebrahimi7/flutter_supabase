import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signInLoading = false;
  bool _signUpLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _googleSignInLoading = false;

  // Sign up functionality
  // Syntax : supabase.auth.signup(email:'',password:'');
  // Sign In Syntax : supabase.auth.signInWithPassword(email:'',password:'');

  @override
  void dispose() {
    // Do not dispose the global Supabase client here
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://images.seeklogo.com/logo-png/43/1/supabase-logo-png_seeklogo-435677.png',
                      height: 150,
                      errorBuilder: (context, _, __) => const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.red),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Email Field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      return null;
                    },
                    controller: _emailController,
                    decoration: const InputDecoration(label: Text("Email")),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  // Password Field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field is required";
                      }
                      return null;
                    },
                    controller: _passwordController,
                    decoration: const InputDecoration(label: Text("Password")),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _signInLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signInLoading = true;
                            });
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            try {
                              await supabase.auth
                                  .signInWithPassword(
                                    email: email,
                                    password: password,
                                  )
                                  .timeout(const Duration(seconds: 20));
                              if (!mounted) return;
                            } on AuthException catch (e) {
                              if (kDebugMode)
                                print('AuthException: ${e.message}');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                              ));
                            } on TimeoutException {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Login timed out. Check network/API keys.'),
                                backgroundColor: Colors.red,
                              ));
                            } catch (e) {
                              if (kDebugMode) print('SignIn error: $e');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ));
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _signInLoading = false;
                                });
                              }
                            }
                          },
                          child: const Text("Sign In")),
                  const SizedBox(
                    height: 16,
                  ),

                  _signUpLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signUpLoading = true;
                            });
                            try {
                              await supabase.auth.signUp(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text("Success ! Confirmation Email Sent"),
                                backgroundColor: Colors.green,
                              ));
                            } on AuthException catch (e) {
                              if (kDebugMode)
                                print('AuthException: ${e.message}');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                              ));
                            } catch (e) {
                              if (kDebugMode) print('SignUp error: $e');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ));
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _signUpLoading = false;
                                });
                              }
                            }
                          },
                          child: const Text("Sign Up")),
                  const SizedBox(
                    height: 16,
                  ),

                  Row(children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(
                    height: 16,
                  ),

                  _googleSignInLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton.icon(
                          onPressed: () async {
                            setState(() {
                              _googleSignInLoading = true;
                            });
                            try {
                              // Syntax for Google Sign in
                              await supabase.auth.signInWithOAuth(
                                  OAuthProvider.google,
                                  redirectTo: kIsWeb
                                      ? null
                                      : 'io.supabase.myflutterapp://login-callback');
                            } on AuthException catch (e) {
                              if (kDebugMode)
                                print('OAuth AuthException: ${e.message}');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                              ));
                            } catch (e) {
                              if (kDebugMode) print('OAuth error: $e');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ));
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _googleSignInLoading = false;
                                });
                              }
                            }
                          },
                          icon: Image.network(
                            "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png",
                            height: 20,
                          ),
                          label: const Text("Continue with Google"))
                ],
              ),
            )),
      )),
    );
  }
}
