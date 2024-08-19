import 'package:flutter/material.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // intro text
            const Center(child: Text('Login'),),

            const SizedBox(height: 16.0,),

            // email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16.0,),


            // password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid password';
                }
                if(value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),

            const SizedBox(height: 16.0,),

            // error message
            if(_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red),),
              ),

            // submit button
            FilledButton.tonal(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _errorMessage = null;
                  });

                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  final user = await AuthService.signIn(email, password);

                  //error feedback
                  if(user == null) {
                    setState(() {
                      _errorMessage = TextLiterals.invalidLoginCredentials;
                    });
                  }
                }
              },
              child: const Text('Login'),
            ),
          ],
        )
      ),
    );
  }
}