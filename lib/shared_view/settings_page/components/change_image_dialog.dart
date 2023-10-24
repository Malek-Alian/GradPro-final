import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../services/firebase/users_firestore.dart';

class ChangeImageDialog extends StatelessWidget {
  const ChangeImageDialog({
    super.key,
    required this.user,
  });

  final UsersFirestore user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'changePicture',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ).tr(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                user.pickGalleryImage();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('selectFromGallery').tr(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                user.pickCameraImage();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.camera),
              label: const Text('takePicture').tr(),
            ),
          ],
        ),
      ),
    );
  }
}
