import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';

class CreateClassForm extends ConsumerStatefulWidget {
  final String institutionId;

  const CreateClassForm({
    super.key,
    required this.institutionId,
  });

  @override
  ConsumerState<CreateClassForm> createState() => _CreateClassFormState();
}

class _CreateClassFormState extends ConsumerState<CreateClassForm> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  bool _isCreatingClass = false;

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  Future<void> _createClass() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCreatingClass = true;
      });

      try {
        await InstitutionClassRepository.createClass(
          institutionId: widget.institutionId,
          className: _classNameController.text.trim(),
        );

        // Refresh classes list
        ref.invalidate(classesProvider);

        if (mounted) {
          _classNameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(TextLiterals.classCreatedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${TextLiterals.failedToCreateClass}$e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCreatingClass = false;
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
                TextLiterals.createNewClass,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: TextLiterals.className,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return TextLiterals.pleaseEnterClassName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isCreatingClass ? null : _createClass,
                child: _isCreatingClass
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(TextLiterals.createClass),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
