import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

enum GallerySaveResult { success, permissionDenied, failed }

Future<GallerySaveResult> saveBundledAssetToGallery(String assetPath) async {
  if (!await _ensureSavePermission()) {
    return GallerySaveResult.permissionDenied;
  }
  try {
    final ByteData byteData = await rootBundle.load(assetPath);
    final Uint8List bytes = byteData.buffer.asUint8List();
    final dynamic result = await ImageGallerySaver.saveImage(
      bytes,
      name: 'wallora_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (result is Map && result['isSuccess'] == false) {
      return GallerySaveResult.failed;
    }
    return GallerySaveResult.success;
  } catch (_) {
    return GallerySaveResult.failed;
  }
}

Future<bool> _ensureSavePermission() async {
  if (kIsWeb) return false;

  if (Platform.isIOS) {
    var status = await Permission.photosAddOnly.status;
    if (status.isGranted || status.isLimited) return true;
    status = await Permission.photosAddOnly.request();
    return status.isGranted || status.isLimited;
  }

  if (Platform.isAndroid) {
    var status = await Permission.photos.status;
    if (status.isGranted) return true;
    status = await Permission.photos.request();
    if (status.isGranted) return true;
    status = await Permission.storage.request();
    return status.isGranted;
  }

  return true;
}
