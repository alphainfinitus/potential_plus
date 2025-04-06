import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/providers/users_provider/users_provider.dart';
import 'package:potential_plus/repositories/user_repository.dart';

class CreateStudentForm extends ConsumerStatefulWidget {
  final String institutionId;

  const CreateStudentForm({
    super.key,
    required this.institutionId,
  });

  @override
  ConsumerState<CreateStudentForm> createState() => _CreateStudentFormState();
}

class _CreateStudentFormState extends ConsumerState<CreateStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isCreatingStudent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _createStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreatingStudent = true;
      });

      try {
        await UserRepository.createStudent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          institutionId: widget.institutionId,
        );

        // Refresh students list
        ref.invalidate(institutionStudentsProvider);

        if (mounted) {
          _nameController.clear();
          _emailController.clear();
          _usernameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(TextLiterals.studentCreatedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${TextLiterals.failedToCreateStudent}$e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCreatingStudent = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                TextLiterals.createNewStudent,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.studentName,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return TextLiterals.pleaseEnterStudentName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.studentEmail,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return TextLiterals.pleaseEnterStudentEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.studentUsername,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return TextLiterals.pleaseEnterStudentUsername;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isCreatingStudent ? null : _createStudent,
                child: _isCreatingStudent
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(TextLiterals.createStudent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
