import 'package:flutter/material.dart';
import 'package:metacolhub/components/my_textfield.dart';
import 'package:metacolhub/helper/helper_functions.dart';
import '../services/firestore_service.dart';

class AddCollocationDialog extends StatefulWidget {
  final FirestoreService firestoreService;

  const AddCollocationDialog({super.key, required this.firestoreService});

  @override
  State<AddCollocationDialog> createState() => _AddCollocationDialogState();
}

class _AddCollocationDialogState extends State<AddCollocationDialog> {
  final TextEditingController baseController = TextEditingController();
  final TextEditingController collocationController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  String? selectedFileId;
  List<Map<String, String>> files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() async {
    var querySnapshot = await widget.firestoreService.getFiles().first;

    if (!mounted) return;

    setState(() {
      files =
          querySnapshot.docs
              .map(
                (doc) => {
                  "id": doc.id,
                  "fileName": doc.get('fileName').toString(),
                },
              )
              .toList();
    });
  }

  void _addCollocation() async {
    if (baseController.text.trim().isEmpty ||
        collocationController.text.trim().isEmpty ||
        exampleController.text.trim().isEmpty ||
        selectedFileId == null) {
      if (!mounted) return;
      displayMessageToUser(
        "Please fill in all fields and select a file",
        context,
      );
      return;
    }

    await widget.firestoreService.addCollocation(
      selectedFileId!,
      baseController.text.trim(),
      collocationController.text.trim(),
      exampleController.text.trim(),
    );

    if (!mounted) return;
    displayMessageToUser("Collocation successfully added", context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Collocation"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextfield(
            hintText: "Enter Base",
            obscureText: false,
            controller: baseController,
          ),
          const SizedBox(height: 10),
          MyTextfield(
            hintText: "Enter Collocation",
            obscureText: false,
            controller: collocationController,
          ),
          const SizedBox(height: 10),
          MyTextfield(
            hintText: "Enter Example",
            obscureText: false,
            controller: exampleController,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: DropdownButtonHideUnderline(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Theme.of(context).dialogBackgroundColor,
                    ),
                    child: DropdownButton<String>(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      borderRadius: BorderRadius.circular(12),
                      value: selectedFileId,
                      hint: const Text("Select a file"),
                      isExpanded: true,
                      items:
                          files.map((file) {
                            return DropdownMenuItem(
                              value: file['id'],
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(file['fileName']!),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFileId = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
              onPressed: _addCollocation,
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
                "Add",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
