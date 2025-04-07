import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:metacolhub/auth/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  //logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 30),
                child: DrawerHeader(
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo_light.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              //home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home_work_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text("H O M E"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/home_page');
                  },
                ),
              ),

              //uploaded files tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.cloud_upload_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text("F I L E S"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/added_files');
                  },
                ),
              ),

              //profile tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person_pin_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text("P R O F I L E"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),
            ],
          ),

          //logout tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 30),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text("L O G O U T"),
              onTap: () async {
                // Log out
                await FirebaseAuth.instance.signOut();

                // Navigate to AuthPage
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
