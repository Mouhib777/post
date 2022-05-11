//import 'dart:html';
//import 'dart:html';
import 'dart:io';
import 'package:bil/Service/DataBase.dart';
import 'package:bil/Service/StorageService.dart';
import 'package:bil/Widget/RoundedButton.dart';
import 'package:bil/constant/constants.dart';
import 'package:bil/model/posting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:uuid/uuid.dart';
//import 'package:bil/Service/PostService.dart';
import 'package:bil/model/user.dart';
import 'package:bil/screens/home/homescreen.dart';
import 'package:bil/screens/home/timelinescreen.dart';

Future<PickedFile> _pickedImage = Future.value(null);

class create_post_screen extends StatefulWidget {
  final String currentUserId;

  const create_post_screen({Key? key, required this.currentUserId})
      : super(key: key);
  @override
  State<create_post_screen> createState() => _create_post_screenState();
}

class _create_post_screenState extends State<create_post_screen> {
  Future<File>? imageFile;
  String? _captionText;
  File? _pickedImage;
  ImagePicker? imagePicker;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  handle_image_gallery() async {
    //try {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    _pickedImage = File(pickedFile!.path);
    // if (imageFile != null) {
    setState(() {
      _pickedImage;
      //XFile _imageFile;
    });
  }
  // } catch (e) {
  // print(e);
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF1C75BC),
        centerTitle: true,
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          TextField(
            maxLength: 280,
            maxLines: 7,
            decoration: InputDecoration(hintText: "What's up ?"),
            onChanged: (value) {
              _captionText = value;
            },
          ),
          SizedBox(
            height: 10,
          ),
          _pickedImage == null
              ? SizedBox.shrink()
              : Column(
                  children: <Widget>[
                    Container(
                      height: 180,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: FileImage(_pickedImage!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: handle_image_gallery,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                border: Border.all(
                  color: Color(0xFF1C75BC),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 50,
                color: Color(0xFF1C75BC),
              ),
            ),
          ),
          SizedBox(height: 20),
          RoundedButton(
              btnText: 'Post',
              onBtnPressed: () async {
                setState(() {
                  _loading = true;
                });
                if (_captionText != null && _captionText!.isNotEmpty) {
                  String image;
                  if (_pickedImage == null) {
                    image = '';
                  } else {
                    image = await StorageService.uploadPostingPicture(
                        _pickedImage!);
                  }
                  Posting posting = Posting(
                      id: widget.currentUserId,
                      text: _captionText!,
                      image: image,
                      authorId: widget.currentUserId,
                      likes: 0,
                      timestamp: Timestamp.fromDate(
                        DateTime.now(),
                      ));
                  DatabaseServices.createPost(posting);
                  Navigator.pop(context);
                }
                setState(() {
                  _loading = false;
                });
              }),
          SizedBox(
            height: 20,
          ),
          _loading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(BIL_Color),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
