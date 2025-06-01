import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final void Function()? onTap;
  const SearchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),

        child: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }
}
