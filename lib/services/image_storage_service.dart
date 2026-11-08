
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
}
