import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// ignore: constant_identifier_names
enum FireStorageError { upload_image_for_news_error }

class FireStorage {
  final firebase_storage.FirebaseStorage firestorage =
      firebase_storage.FirebaseStorage.instance;

  // static Future changeNadiProfilePic(String path, String )

  Future<String> uploadImageForNews(
      File file, DocumentReference nadiDoc) async {
    try {
      final String fileId = const Uuid().v4();
      final String nadiId = nadiDoc.id;
      firebase_storage.Reference _storage = firebase_storage
          .FirebaseStorage.instance
          .ref("$nadiId/images/$fileId.jpg");
      firebase_storage.TaskSnapshot uploadTask = await _storage.putFile(file);

      String url = await uploadTask.ref.getDownloadURL();

      return url;
    } catch (e) {
      print(e.toString());
      // return Future.error(e);
      return Future.error(FireStorageError.upload_image_for_news_error);
    }
  }

  static Future saveImage(String url) async {
    try {
      final String fileId = const Uuid().v4();
      final String dir = (await getTemporaryDirectory()).path;
      final String fullPath = '$dir/$fileId.jpg';
      final File capturedFile = await File(fullPath).create();
      final response = await get(Uri.parse(url));
      final finalFile = await capturedFile.writeAsBytes(response.bodyBytes);

      bool? isSaved = await GallerySaver.saveImage(finalFile.absolute.path,
          albumName: "Downloads");

      // remove the image from the cache
      if (isSaved!) {
        await capturedFile.delete();
      }

      return isSaved;
    } catch (e) {
      print(e.toString()); // TODO: Test
    }
  }
}
