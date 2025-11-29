import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucky_parcel/common/widgets/primary_button.dart';
import 'package:lucky_parcel/common/widgets/custom_text_field.dart';
import 'package:lucky_parcel/common/widgets/gradient_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "An unknown error occurred."), backgroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: GradientBackground(
        showBlobs: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                    'Register to continue',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: SvgPicture.asset('assets/icons/user.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: SvgPicture.asset('assets/icons/password.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: 'Sign Up',
                          onPressed: _signUp,
                        ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
