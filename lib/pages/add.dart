import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo/api/list_api.dart';
import 'package:todo/models/todo.dart';

class AddPage extends StatefulWidget {
  @override
  State<AddPage> createState() => AppPageState();
}

class AppPageState extends State<AddPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _key = GlobalKey<FormState>();
  late File _image;
  final firebaseStorage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Add TODO'),
        ),
        body: ListView(
          children: [
            Form(
              key: _key,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: _title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required !!';
                        }
                      },
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: _content,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Content is required !!';
                        }
                      },
                      decoration: InputDecoration(labelText: 'Content'),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: showPicker, icon: Icon(Icons.add_a_photo))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var path;
            _key.currentState!.validate();
            UploadTask task = firebaseStorage.ref(_image.path).putFile(_image);
            path = await (await task).ref.getDownloadURL();

            Todo todo = Todo(
                title: _title.text.trim(),
                content: _content.text.trim(),
                uid: FirebaseAuth.instance.currentUser!.uid,
                imagePath: path);
            ListApi().addTodo(todo: todo, context: context);
          },
          child: Icon(Icons.save),
        ),
      );

  void showPicker() => showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Gallery'),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      });

  _imgFromCamera() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
  }
}
