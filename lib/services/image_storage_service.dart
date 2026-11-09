
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ImageStorageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image == null) return null;

    final directory =
    await getApplicationDocumentsDirectory();

    final imageDirectory = Directory(
      p.join(directory.path, 'recipe_images'),
    );

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final fileName =
        '${const Uuid().v4()}${p.extension(image.path)}';

    final savedImage = await File(image.path).copy(
      p.join(imageDirectory.path, fileName),
    );

    return savedImage.path;
  }


  Future<String> downloadRecipeImage({
    required String imageUrl,
    required String recipeId,
  }) async {
    final uri = Uri.tryParse(imageUrl);

    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Invalid image URL');
    }

    // Download image from remote API.
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to download image: HTTP ${response.statusCode}',
        uri: uri,
      );
    }

    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';

    // Accept supported image formats.
    String extension;

    if (contentType.contains('image/jpeg')) {
      extension = '.jpg';
    } else if (contentType.contains('image/png')) {
      extension = '.png';
    } else if (contentType.contains('image/webp')) {
      extension = '.webp';
    } else {
      throw const FormatException('Unsupported image format');
    }

    if (response.bodyBytes.isEmpty) {
      throw const FormatException('Empty image response');
    }

    // Prevent unexpected file names.
    final safeRecipeId = recipeId.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );

    // Save inside app documents directory.
    final documentsDirectory =
    await getApplicationDocumentsDirectory();

    final imageDirectory = Directory(
      p.join(documentsDirectory.path, 'recipe_images'),
    );

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final filePath = p.join(
      imageDirectory.path,
      '$safeRecipeId$extension',
    );

    final file = File(filePath);

    await file.writeAsBytes(
      response.bodyBytes,
      flush: true,
    );

    return file.path;
  }
}
