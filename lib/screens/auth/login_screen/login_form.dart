import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // intro text
            Center(
              child: Text(
                TextLiterals.appTitle,
                style: GoogleFonts.micro5(fontSize: 48),
              ),
            ),
            
            const SizedBox(height: 32.0,),
              
            // email field
            TextFormField(
              controller: _emailController,
              readOnly: _isLoading,
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
              readOnly: _isLoading,
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
          
            const SizedBox(height: 16.0,),
        
            // submit button
            FilledButton.tonal(
              onPressed: () async {
                if (_formKey.currentState!.validate() && !_isLoading) {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
        
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
        
                  final user = await AuthService.signIn(email, password);
        
                  //error feedback
                  if(user == null) {
                    setState(() {
                      _errorMessage = TextLiterals.invalidLoginCredentials;
                      _isLoading = false;
                    });
                  }
                }
              },
              child: _isLoading ?
                Transform.scale(
                  scale: 0.5,
                  child: const CircularProgressIndicator()
                ) : 
                const Text('Login'),
            ),
        
            TextButton(
              onPressed: (){
                Navigator.pushNamed(context, AppRoutes.forgotPassword.path);
              },
              child: const Text('Forgot Password?')
            ),
          ],
        )
      ),
    );
  }
}