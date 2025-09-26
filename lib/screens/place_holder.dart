import 'package:flutter/material.dart';

class PlaceHolderPage extends StatelessWidget {
  const PlaceHolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('This page is a place holder', style: theme.textTheme.headlineSmall),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          Text("Random text"),
          SizedBox(width: 8, height: 8,),
          ElevatedButton(onPressed: () => {}, child: Text("Text on Button"))
        ],
      )
    );
  }
}
