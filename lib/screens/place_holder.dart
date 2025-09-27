import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class PlaceHolderPage extends StatelessWidget {
  const PlaceHolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.thisPageIsAPlaceHolder, style: theme.textTheme.headlineSmall),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          Text(loc.randomText),
          SizedBox(width: 8, height: 8,),
          ElevatedButton(onPressed: () => {}, child: Text(loc.textOnButton))
        ],
      )
    );
  }
}
