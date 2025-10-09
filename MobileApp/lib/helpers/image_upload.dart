import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/widgets.dart';
import '../l10n/app_localizations.dart';


Future<void> _checkPermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

Future<String?> uploadImage(BuildContext context, File? selectedImage) async {
  if (selectedImage == null) return null;
  await _checkPermission();
  final loc = AppLocalizations.of(context)!;
  try {
    final imageBytes = await selectedImage.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // Upload image to Imgur
    final imageUploadResponse = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {
        'Authorization': 'Client-ID 9f9ec81a2a40523',
      },
      body: {
        'image': base64Image,
        'type': 'base64',
      },
    );

    if (imageUploadResponse.statusCode != 200) {
      throw Exception(loc.failedToUploadImage);
    }

    final imageUploadJson = jsonDecode(imageUploadResponse.body);
    final imageUrl = imageUploadJson['data']['link'];

    return imageUrl;
  } catch (e) {
    showCustomSnackBar(context, loc.errorOccurredWhileUploadingImage(e));
  }
  return null;
}

Future<File?> pickImage() async {
  await _checkPermission();
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
      return File(pickedFile.path);
  }
  return null;
}