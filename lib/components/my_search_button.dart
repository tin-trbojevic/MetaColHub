import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  final void Function()? onTap;
  const SearchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(left: 10),
        child: Center(
          child: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.background,
          ),
        ),
      ),
    );
  }
}
