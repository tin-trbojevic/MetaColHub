import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metacolhub/auth/auth.dart';
import 'package:metacolhub/helper/helper_functions.dart';
import 'package:metacolhub/theme/dark_mode.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'package:metacolhub/components/my_delete_confirmation_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  Future<void> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirmed = await showDeleteConfirmationDialog(
      context,
      user.email.toString(),
    );

    if (confirmed == null || !confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final filesSnapshot =
          await firestore
              .collection('uploaded_files')
              .where('userId', isEqualTo: user.uid)
              .get();

      for (var file in filesSnapshot.docs) {
        final collocationsSnapshot =
            await file.reference.collection('collocations').get();

        for (var colloc in collocationsSnapshot.docs) {
          await colloc.reference.delete();
        }

        await file.reference.delete();
      }

      if (user.email != null) {
        await firestore.collection('Users').doc(user.email!).delete();
      }

      await user.delete();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    } catch (e) {
      displayMessageToUser(e.toString(), context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeData == darkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(23.0),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 24),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: CupertinoSwitch(
                              value: isDarkMode,
                              onChanged: (bool value) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onTap: () => deleteAccount(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_forever,
                              size: 24,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
