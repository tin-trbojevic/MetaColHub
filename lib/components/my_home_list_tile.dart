import 'package:flutter/material.dart';

class HomeListTile extends StatelessWidget {
  final String base;
  final List<String> collocations;
  final VoidCallback onTap;

  const HomeListTile({
    super.key,
    required this.base,
    required this.collocations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String collocationsText =
        collocations.length > 2
            ? "${collocations.sublist(0, 2).join(', ')}..."
            : collocations.join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          hoverColor: Theme.of(context).hoverColor,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        base,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inverseSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collocationsText,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
