import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/authservice.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isChecked = false; // State for checkbox

  void _handleSignUp(
      String email, String password, String role, String phone) async {
    if (_formKey.currentState!.validate() && _isChecked) {
      // Ensure checkbox is checked
      setState(() {
        _isLoading = true;
      });

      try {
        bool success = await _authService.signup(email, password, role, phone);
        if (success) {
          Navigator.pushNamed(context, entryPointScreenRoute);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please accept the terms and conditions.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/signUp_dark.png",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),

                  // Updated to pass phone field
                  SignUpForm(
                    formKey: _formKey,
                    onSubmit: _handleSignUp,
                  ),

                  const SizedBox(height: defaultPadding),

                  // Checkbox for Terms & Conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, termsOfServicesScreenRoute);
                                  },
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: defaultPadding * 2),

                  // Continue button with loader
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (!_isLoading)
                    ElevatedButton(
                      onPressed: () {
                        if (!_isChecked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please accept the terms and conditions."),
                            ),
                          );
                          return;
                        }

                        // Simply validate and save the form
                        final formState = _formKey.currentState;
                        if (formState != null && formState.validate()) {
                          formState
                              .save(); // This will trigger the onSaved callbacks
                        }
                      },
                      child: const Text("Continue"),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
