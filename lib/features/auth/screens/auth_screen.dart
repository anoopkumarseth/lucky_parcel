import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucky_parcel/common/widgets/primary_button.dart';
import 'package:lucky_parcel/common/widgets/custom_text_field.dart';
import 'package:lucky_parcel/common/widgets/gradient_background.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  var _authMode = AuthMode.login;
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      // The AuthWrapper will handle successful navigation
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "An unknown error occurred."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isLogin = _authMode == AuthMode.login;

    return Scaffold(
      body: GradientBackground(
        showBlobs: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, Welcome to',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 16),
                    SvgPicture.asset(
                      'assets/images/LuckyParcel_logo.svg',
                      width: 245,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isLogin ? 'Login to continue' : 'Register to continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: SvgPicture.asset('assets/icons/user.svg', colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: SvgPicture.asset('assets/icons/password.svg', colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
                      obscureText: _isObscured,
                      suffixIcon: IconButton(
                        icon: SvgPicture.asset(
                          _isObscured ? 'assets/icons/eye-closed.svg' : 'assets/icons/eye-open.svg',
                          colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      PrimaryButton(
                        text: isLogin ? 'Login' : 'Sign Up',
                        onPressed: _submit,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isLogin ? "Don't have an account?" : "Already have an account?"),
                        TextButton(
                          onPressed: _switchAuthMode,
                          child: Text(isLogin ? 'Sign Up' : 'Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
