import 'package:flutter/material.dart';
import 'package:metacolhub/components/my_textfield.dart';

class EditCollocationDialog extends StatelessWidget {
  final TextEditingController baseController;
  final TextEditingController collocationController;
  final TextEditingController exampleController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditCollocationDialog({
    super.key,
    required this.baseController,
    required this.collocationController,
    required this.exampleController,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: AlertDialog(
        title: const Text('Edit Collocation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextfield(
              hintText: "Enter Base",
              obscureText: false,
              controller: baseController,
              maxLines: 10,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              hintText: "Enter Collocation",
              obscureText: false,
              controller: collocationController,
              maxLines: 10,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              hintText: "Enter Example",
              obscureText: false,
              controller: exampleController,
              maxLines: 10,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showEditCollocationDialog({
  required BuildContext context,
  required String currentBase,
  required String currentCollocation,
  required String currentExample,
  required Function(String, String, String) onConfirm,
}) async {
  final baseController = TextEditingController(text: currentBase);
  final collocationController = TextEditingController(text: currentCollocation);
  final exampleController = TextEditingController(text: currentExample);

  await showDialog(
    context: context,
    builder:
        (context) => EditCollocationDialog(
          baseController: baseController,
          collocationController: collocationController,
          exampleController: exampleController,
          onCancel: () => Navigator.pop(context),
          onSave: () {
            onConfirm(
              baseController.text.trim(),
              collocationController.text.trim(),
              exampleController.text.trim(),
            );
            Navigator.pop(context);
          },
        ),
  );
}
