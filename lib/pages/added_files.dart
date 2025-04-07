import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metacolhub/components/my_delete_confirmation_dialog.dart';
import 'package:metacolhub/components/my_drawer.dart';
import 'package:metacolhub/helper/helper_functions.dart';
import 'package:metacolhub/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddedFiles extends StatefulWidget {
  const AddedFiles({super.key});

  @override
  AddedFilesState createState() => AddedFilesState();
}

class AddedFilesState extends State<AddedFiles> {
  final FirestoreService firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uploaded Files"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: MyDrawer(),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: StreamBuilder(
                  stream: firestoreService.getUserFiles(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No files uploaded. Please upload a CSV file.",
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var file = snapshot.data!.docs[index];
                        return Card(
                          color: Theme.of(context).colorScheme.primary,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              file['fileName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "Uploaded on: \n${file['uploadedAt'] != null ? DateFormat('dd.MM.yyyy – HH:mm').format(file['uploadedAt'].toDate()) : 'Unknown date'}",
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  tooltip: 'Export CSV',
                                  onPressed: () async {
                                    await firestoreService.exportFileAsCSV(
                                      context,
                                      file.id,
                                      file['fileName'],
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    bool? confirmDelete =
                                        await showDeleteConfirmationDialog(
                                          context,
                                          file['fileName'],
                                        );

                                    if (confirmDelete == true) {
                                      setState(() => _isLoading = true);
                                      await firestoreService.deleteFile(
                                        file.id,
                                      );
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(7.0),
        child: FloatingActionButton(
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              await firestoreService.pickAndUploadFiles();
            } catch (e) {
              if (context.mounted) {
                displayMessageToUser("Error: $e", context);
              }
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          },
          elevation: 5,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          tooltip: 'Upload Files',
          child: const Icon(Icons.upload_file),
        ),
      ),
    );
  }
}
