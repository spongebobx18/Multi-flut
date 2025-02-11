import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(String email, String password, String phone, String role)
      onSubmit;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = "BUYER"; // Changed from "Buyer" to "BUYER"

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.formKey.currentState!.validate()) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
        _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Phone field
          TextFormField(
            controller: _phoneController,
            onSaved: (value) => _handleSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Phone number is required";
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "Phone Number",
            ),
          ),
          const SizedBox(height: defaultPadding),

          // Email field
          TextFormField(
            controller: _emailController,
            onSaved: (value) => _handleSubmit(),
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),

          // Password field
          TextFormField(
            controller: _passwordController,
            onSaved: (value) => _handleSubmit(),
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),

          // Role dropdown (Buyer/Seller)
          DropdownButtonFormField<String>(
            value: _selectedRole,
            onSaved: (value) => _handleSubmit(),
            decoration: const InputDecoration(
              labelText: "Select Role",
              border: OutlineInputBorder(),
            ),
            items: const ["BUYER", "SELLER"].map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role == "BUYER" ? "Buyer" : "Seller"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}
