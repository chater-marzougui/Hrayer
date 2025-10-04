import 'dart:io';

import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageCompressor {
  static const int maxFileSize = 1024 * 1024; // 1MB
  static const int maxDimension = 1024; // Max width/height

  static Future<Uint8List?> compressImage(File imageFile, {int quality = 85}) async {
    try {
      final originalBytes = await imageFile.readAsBytes();

      // If image is already small enough, return as is
      if (originalBytes.length <= maxFileSize) {
        return originalBytes;
      }

      // Decode the image
      final image = img.decodeImage(originalBytes);
      if (image == null) return null;

      // Resize if too large
      img.Image resizedImage = image;
      if (image.width > maxDimension || image.height > maxDimension) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? maxDimension : null,
          height: image.height > image.width ? maxDimension : null,
          maintainAspect: true,
        );
      }

      // Encode with compression and convert to Uint8List
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      final uint8List = Uint8List.fromList(compressedBytes);

      // If still too large, reduce quality further
      if (uint8List.length > maxFileSize) {
        final furtherCompressed = img.encodeJpg(resizedImage, quality: 70);
        return Uint8List.fromList(furtherCompressed);
      }

      return uint8List;
    } catch (e) {
      print('Image compression error: $e');
      return null;
    }
  }
}