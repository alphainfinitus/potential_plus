import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/providers/users_provider/users_provider.dart';
import 'package:potential_plus/repositories/user_repository.dart';

class CreateTeacherForm extends ConsumerStatefulWidget {
  final String institutionId;

  const CreateTeacherForm({
    super.key,
    required this.institutionId,
  });

  @override
  ConsumerState<CreateTeacherForm> createState() => _CreateTeacherFormState();
}

class _CreateTeacherFormState extends ConsumerState<CreateTeacherForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isCreatingTeacher = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _createTeacher() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreatingTeacher = true;
      });

      try {
        await UserRepository.createTeacher(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          institutionId: widget.institutionId,
        );

        // Refresh teachers list
        ref.invalidate(institutionTeachersProvider);

        if (mounted) {
          _nameController.clear();
          _emailController.clear();
          _usernameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(TextLiterals.teacherCreatedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${TextLiterals.failedToCreateTeacher}$e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCreatingTeacher = false;
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
                TextLiterals.createNewTeacher,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.teacherName,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return TextLiterals.pleaseEnterTeacherName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.teacherEmail,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return TextLiterals.pleaseEnterTeacherEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.teacherUsername,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return TextLiterals.pleaseEnterTeacherUsername;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isCreatingTeacher ? null : _createTeacher,
                child: _isCreatingTeacher
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(TextLiterals.createTeacher),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
