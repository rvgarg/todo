import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo/api/list_api.dart';
import 'package:todo/models/todo.dart';

class EditPage extends StatefulWidget {
  EditPage({Key? key, required this.todo}) : super(key: key);
  final Todo todo;

  @override
  State<StatefulWidget> createState() {
    return EditPageState();
  }
}

class EditPageState extends State<EditPage> {
  final _key = GlobalKey<FormState>();
  var firebaseStorage = FirebaseStorage.instance;
  late File _image;

  @override
  Widget build(BuildContext context) {
    var _title = TextEditingController();
    final _content = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add TODO'),
      ),
      body: Form(
        key: _key,
        child: Stack(
          children: [
            Column(
              children: [
                TextFormField(
                  controller: _title = TextEditingController(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title required';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Title'),
                  initialValue: widget.todo.title,
                ),
                TextFormField(
                  controller: _content,
                  initialValue: widget.todo.content,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content is required';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  expands: true,
                ),
                IconButton(
                  onPressed: () => showPicker(),
                  icon: Icon(Icons.image_search),
                ),
                Image.network(widget.todo.imagePath),
              ],
            ),
            Align(
              child: ElevatedButton(
                child: Text('UPDATE'),
                onPressed: () {
                  var path;
                  _key.currentState!.validate();
                  firebaseStorage
                      .ref(_image.path)
                      .putFile(_image)
                      .whenComplete(() async {
                    path =
                        await firebaseStorage.ref(_image.path).getDownloadURL();
                  });
                  Todo todo = Todo(
                      title: _title.text.trim(),
                      content: _content.text.trim(),
                      imagePath: path);
                  ListApi().updateTodo(todo: todo, context: context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

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
      _image = image as File;
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image as File;
    });
  }
}
