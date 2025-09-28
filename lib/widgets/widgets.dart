import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../structures/structs.dart' as structs;

part 'additional_user_data_dialog.dart';
part 'welcome_message.dart';
part 'loading_screen.dart';
part 'snack_bar.dart';
part 'typing_indicator.dart';

Widget settingScreenItem(
    BuildContext context, {
      IconData? icon,
      String? imagePath,
      required String itemName,
      required page,
    }) {
  final theme = Theme.of(context);

  return ListTile(
    leading: SizedBox(
      width: 24,
      height: 24,
      child: icon != null
          ? Center(child: Icon(icon, color: theme.primaryColor, size: 22))
          : imagePath != null
          ? Center(child: Image.asset(imagePath, width: 20, height: 20))
          : null,
    ),
    title: Text(itemName, style: theme.textTheme.titleSmall),
    onTap: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}


Widget buildTextField(
    BuildContext context, TextEditingController controller, String label,
    {bool obscureText = false, String? Function(String?)? validator}) {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context)!;
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      fillColor: theme.inputDecorationTheme.fillColor,
      filled: true,
    ),
    style: theme.textTheme.titleSmall,
    obscureText: obscureText,
    validator: validator ??
            (value) {
          if (value == null || value.isEmpty) {
            return loc.pleaseEnterLabel(label);
          }
          return null;
        },
  );
}
