import 'package:flutter/material.dart';

class CustomFormField {
  final String name;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomFormField({
    required this.name,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });
}

class FormDialog extends StatelessWidget {
  final String title;
  final List<CustomFormField> fields;
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSubmit;
  final String submitButtonText;
  final Map<String, dynamic>? initialValues;

  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onCancel,
    required this.onSubmit,
    required this.submitButtonText,
    this.initialValues,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controllers = <String, TextEditingController>{};

    // Khởi tạo controllers với giá trị ban đầu nếu có
    for (var field in fields) {
      controllers[field.name] = TextEditingController(
        text: initialValues?[field.name] ?? '',
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 14, 19, 29),
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: controllers[field.name],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        labelText: field.label,
                        hintText: field.hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            field.icon != null
                                ? Icon(
                                  field.icon,
                                  color: const Color.fromARGB(255, 16, 80, 98),
                                )
                                : null,
                      ),
                      keyboardType: field.keyboardType,
                      validator: field.validator,
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color.fromARGB(255, 16, 80, 98)),
          ),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final values = <String, dynamic>{};
              for (var field in fields) {
                values[field.name] = controllers[field.name]!.text;
              }
              onSubmit(values);
            }
          },
          child: Text(
            submitButtonText,
            style: const TextStyle(
              color: Color.fromARGB(255, 16, 80, 98),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
