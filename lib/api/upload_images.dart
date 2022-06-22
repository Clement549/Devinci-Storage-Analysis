

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path/path.dart' as p;

final ImagePicker _picker = ImagePicker(); 

class UploadImages {

  static Future<String> pickImage(ImageSource source, bool cropCircle, bool fixedRatio, String id) async {

    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) {
      return null;
    }

    if(!kIsWeb){
      
      File file;
      if(cropCircle)
      // ignore: curly_braces_in_flow_control_structures  // _picker
      file = await ImageCropper().cropImage(sourcePath: pickedFile.path, cropStyle: CropStyle.circle, aspectRatioPresets: [CropAspectRatioPreset.original, CropAspectRatioPreset.square, CropAspectRatioPreset.ratio4x3],); //aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1)
      if(!cropCircle){
        if(fixedRatio)
        file = await ImageCropper().cropImage(sourcePath: pickedFile.path, cropStyle: CropStyle.rectangle, aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3));
        if(!fixedRatio)
        file = await ImageCropper().cropImage(sourcePath: pickedFile.path, cropStyle: CropStyle.rectangle, aspectRatioPresets: [CropAspectRatioPreset.original, CropAspectRatioPreset.square, CropAspectRatioPreset.ratio4x3],);
      }
      
      if (file == null) {
        return null;
      }

      file = await compressImagePath(file.path, 80);

      String url = await uploadFile(file.path, file, id);

      return url;
    }
    else{

      var file = await compressImagePath(pickedFile.path, 80);

      String url = await uploadFile(file.path, file, id);

      return  url;
      //file.path
    }
  }

  static Future<File> compressImagePath(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path, '${DateTime.now()}.${p.extension(path)}'); // crash web

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    return result;
  }

  static Future<String> uploadFile(String path, File file, String id) async {

    var uuid = const Uuid();

    final ref = storage.FirebaseStorage.instance.ref()
      .child('capteurs')
      .child('${uuid.v4()}.jpg');

    //setState(() { imageUrl = fileUrl; });
    //widget.onFileChanged(fileUrl);

    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();

    var image = await decodeImageFromList(file.readAsBytesSync());
    print("height : " + image.height.toString());

    await FirebaseFirestore.instance.collection('capteurs').doc(id).update({'img1': fileUrl});

    return fileUrl;
  }

  static void DeleteFile(String url, String id) async {

     if(url != null){

        FirebaseFirestore.instance.collection('capteurs').doc(id).update({'img1': ""});

        FirebaseStorage.instance.refFromURL(url).delete();
     }
  }

}