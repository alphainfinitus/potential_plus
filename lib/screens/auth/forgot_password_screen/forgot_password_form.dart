import 'package:flutter/material.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/services/auth_service.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  
  String? _errorMessage;
  bool _isLoading = false;
  bool _isEmailSent = false;

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });

      final email = _emailController.text.trim();

      try {
        await AuthService.sendPasswordResetEmail(email);
        setState(() {
          _isEmailSent = true;
        });
      } catch (e) {
        setState(() {
          _errorMessage = TextLiterals.invalidEmail;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmailSent) {
      return const Center(child: Text('Please check your email for a password reset link.'));
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
        
            // error message
            if(_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red),),
              ),
          
            const SizedBox(height: 8.0,),
        
            // submit button
            FilledButton.tonal(
              onPressed: () async {
                await onSubmit();
              },
              child: _isLoading ?
                Transform.scale(
                  scale: 0.5,
                  child: const CircularProgressIndicator()
                ) : 
                const Text('Send Reset Email'),
            ),
          ],
        )
      ),
    );
  }
}