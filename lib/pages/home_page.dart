import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:metacolhub/components/my_add_coll_dialog.dart';
import 'package:metacolhub/components/my_drawer.dart';
import 'package:metacolhub/components/my_home_list_tile.dart';
import 'package:metacolhub/components/my_search_button.dart';
import 'package:metacolhub/components/my_textfield.dart';
import 'package:metacolhub/pages/detail_view.dart';
import '../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore service
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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
        title: const Text("MetaColHub"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(23.0),
                child: Row(
                  children: [
                    // Search text field
                    Expanded(
                      child: MyTextfield(
                        hintText: "Search collocations...",
                        obscureText: false,
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.trim();
                          });
                        },
                      ),
                    ),

                    // Search button
                    SearchButton(
                      onTap: () {
                        setState(() {
                          searchQuery = searchController.text.trim();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Search results displayed as tiles
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestoreService.searchCollocations(searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 70),
                          Lottie.asset('assets/home2.json'),
                          const SizedBox(height: 20),
                          const Text(
                            'No collocations found',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    }

                    List<Map<String, dynamic>> collocations = snapshot.data!;

                    // Create a map to group collocations by base (no duplicates)
                    Map<String, List<String>> groupedByBase = {};

                    for (var colloc in collocations) {
                      String base = colloc['base'];
                      String collocation = colloc['collocation'];

                      if (!groupedByBase.containsKey(base)) {
                        groupedByBase[base] = [];
                      }
                      groupedByBase[base]!.add(collocation);
                    }
                    return ListView.builder(
                      itemCount: groupedByBase.length,
                      itemBuilder: (context, index) {
                        String base = groupedByBase.keys.elementAt(index);
                        List<String> baseCollocations = groupedByBase[base]!;

                        return HomeListTile(
                          base: base,
                          collocations: baseCollocations,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailView(base: base),
                              ),
                            );

                            setState(() {});
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(7.0),
        child: FloatingActionButton(
          elevation: 5,
          onPressed: addCollocationBox,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          tooltip: 'Add Collocation',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
