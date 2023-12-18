import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  XFile? selectedImage;
  List<XFile>? selectedImagesList;

  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker'),
        actions: [
          // create a button that will remove the selected image
          // from the screen
          IconButton(
              onPressed: () {
                setState(() {
                  selectedImage = null;
                  selectedImagesList!.clear();
                });
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                pickeImage(false);
              },
              child: const Text('Select Multiple Image From Photos')),
          // create a button to pick video
          ElevatedButton(
              onPressed: () {
                pickVideo();
              },
              child: const Text('Select Video From Photos')),

          RepaintBoundary(
            key: _globalKey,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 200,
                  width: 200,
                  color: Colors.red,
                )),
          ),

          ElevatedButton(
              onPressed: () {
                capturePng();
              },
              child: const Text('Capture SS')),
          selectedImagesList != null
              ? Expanded(
                  child: GridView.builder(
                      itemCount: selectedImagesList!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return Image.file(
                            File(selectedImagesList![index].path));
                      }),
                )
              : Container(),
        ],
      ),
    );
  }

  Future pickeImage(bool fromCamera) async {
    try {
      final image = await ImagePicker().pickImage(
          source: fromCamera ? ImageSource.camera : ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 50);
      if (image != null) {
        setState(() {
          selectedImage = image;
          // convertToBase64();
          // uploadImage();
        });
      }
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }

  Future pickMultipleImage() async {
    try {
      List<XFile> images = await ImagePicker().pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          selectedImagesList = images;
        });
      }
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }

  Future pickVideo() async {
    try {
      await ImagePicker().pickVideo(source: ImageSource.gallery).then((value) {
        // create code to\ Play the video on new screen
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          final VideoPlayerController _controller =
              VideoPlayerController.networkUrl(Uri.parse(
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'));

          _controller.initialize();
          _controller.play();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Video Player'),
            ),
            body: Center(
                child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )),
          );
        }));
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future uploadImage() async {
    log('Image Upload started');
    final dio = Dio();

    dio
        .post(
      'https://v2.convertapi.com/upload',
      data: FormData.fromMap(
        {
          'file': await MultipartFile.fromFile(selectedImage!.path,
              filename: 'upload.jpg')
        },
      ),
    )
        .then((value) {
      log(value.toString());
    }).catchError((e) {
      log(e.toString());
    });
  }

  void convertToBase64() async {
    final bytes = await File(selectedImage!.path).readAsBytes();
    final base64 = base64Encode(bytes);
    log(base64);
  }

  void convertToImageFromBase64(String base64) async {
    final decodedBytes = base64Decode(base64);
    final image = Image.memory(decodedBytes);
    log(image.toString());
  }

  Future<void> capturePng() async {
    try {
      final boundary = _globalKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      String dir = (await getApplicationDocumentsDirectory()).path;
      String fullPath = '$dir/${DateTime.now().millisecondsSinceEpoch}.png';
      File file = File(fullPath);
      log(pngBytes.toString());
      final result = await ImageGallerySaver.saveImage(pngBytes);
      log('Image saved to gallery');
    } catch (e) {
      log(e.toString());
    }
  }
}


//  CroppedFile? croppedFile = await ImageCropper().cropImage(
//           sourcePath: selectedImage!.path,
//           aspectRatioPresets: [
//             CropAspectRatioPreset.square,
//             CropAspectRatioPreset.ratio3x2,
//             CropAspectRatioPreset.original,
//             CropAspectRatioPreset.ratio4x3,
//             CropAspectRatioPreset.ratio16x9
//           ],
//           uiSettings: [
//             AndroidUiSettings(
//                 toolbarTitle: 'Cropper',
//                 toolbarColor: Colors.deepOrange,
//                 toolbarWidgetColor: Colors.white,
//                 initAspectRatio: CropAspectRatioPreset.original,
//                 lockAspectRatio: false),
//             IOSUiSettings(
//               title: 'Cropper',
//             ),
//             WebUiSettings(
//               context: context,
//             ),
//           ],
//         );