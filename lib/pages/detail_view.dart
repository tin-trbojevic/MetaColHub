import 'package:flutter/material.dart';
import 'package:metacolhub/components/my_add_coll_dialog.dart';
import 'package:metacolhub/components/my_delete_confirmation_dialog.dart';
import 'package:metacolhub/components/my_detail_list_tile.dart';
import 'package:metacolhub/components/my_edit_coll_dialog.dart';
import '../services/firestore_service.dart';
import 'package:metacolhub/helper/helper_functions.dart';

class DetailView extends StatefulWidget {
  final String base;

  const DetailView({Key? key, required this.base}) : super(key: key);

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  final FirestoreService firestoreService = FirestoreService();
  Set<String> selectedLetters = {};

  Future<List<String>> _getDistinctInitialLetters() async {
    final snapshot =
        await firestoreService.getCollocationsByBase(widget.base).first;
    final letters =
        snapshot
            .map(
              (c) => c['collocation']?.toString().substring(0, 1).toUpperCase(),
            )
            .where((letter) => letter != null)
            .toSet()
            .toList();
    letters.sort();
    return letters.cast<String>();
  }

  void addCollocationBox() async {
    await showDialog(
      context: context,
      builder:
          (context) => AddCollocationDialog(firestoreService: firestoreService),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Collocations for ${widget.base}"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15),
            child: FutureBuilder<List<String>>(
              future: _getDistinctInitialLetters(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final letters = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        letters.map((letter) {
                          final isSelected = selectedLetters.contains(letter);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: ChoiceChip(
                              label: Text(letter),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedLetters.add(letter);
                                  } else {
                                    selectedLetters.remove(letter);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: StreamBuilder(
                    stream: firestoreService.getCollocationsByBase(widget.base),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Something went wrong: ${snapshot.error}',
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No collocations found."),
                        );
                      }

                      var collocations = snapshot.data!;
                      if (selectedLetters.isNotEmpty) {
                        collocations =
                            collocations
                                .where(
                                  (c) =>
                                      c['collocation'] != null &&
                                      selectedLetters.contains(
                                        c['collocation']
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                      ),
                                )
                                .toList();
                      }

                      return ListView.builder(
                        itemCount: collocations.length,
                        itemBuilder: (context, index) {
                          var colloc = collocations[index];

                          final collocation =
                              colloc['collocation'] ?? 'No collocation';
                          final example = colloc['example'] ?? 'No example';
                          final base = colloc['base'] ?? 'No base';
                          final fileId = colloc['fileId'];
                          final collocationId = colloc['id'];

                          return DetailListTile(
                            base: base,
                            collocation: collocation,
                            example: example,
                            onEdit: () async {
                              await showEditCollocationDialog(
                                context: context,
                                currentBase: base,
                                currentCollocation: collocation,
                                currentExample: example,
                                onConfirm: (
                                  newBase,
                                  newCollocation,
                                  newExample,
                                ) async {
                                  await firestoreService.editCollocation(
                                    fileId: fileId,
                                    collocationId: collocationId,
                                    newBase: newBase,
                                    newCollocation: newCollocation,
                                    newExample: newExample,
                                  );
                                  setState(() {});
                                  displayMessageToUser(
                                    "Collocation updated successfully",
                                    context,
                                  );
                                },
                              );
                            },
                            onDelete: () async {
                              bool? confirmDelete =
                                  await showDeleteConfirmationDialog(
                                    context,
                                    collocation,
                                  );
                              if (confirmDelete == true) {
                                await firestoreService.deleteCollocation(
                                  fileId,
                                  collocationId,
                                );
                                setState(() {});
                                displayMessageToUser(
                                  "Collocation deleted successfully",
                                  context,
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (selectedLetters.isNotEmpty)
              FloatingActionButton(
                elevation: 5,
                heroTag: 'clearFilters',
                onPressed: () {
                  setState(() {
                    selectedLetters.clear();
                  });
                },
                backgroundColor: Colors.grey,
                tooltip: 'Clear Filters',
                foregroundColor: Colors.red,
                child: const Icon(Icons.clear),
              ),
            const SizedBox(width: 12),
            FloatingActionButton(
              elevation: 5,
              heroTag: 'addCollocation',
              onPressed: addCollocationBox,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              tooltip: 'Add Collocation',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
