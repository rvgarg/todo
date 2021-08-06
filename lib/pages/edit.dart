import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
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
  File? _image;

  @override
  Widget build(BuildContext context) {
    var _title = TextEditingController(text: widget.todo.title);
    final _content = TextEditingController(text: widget.todo.content);
    return Scaffold(
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
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: _title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title required';
                      }
                    },
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: _content,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Content is required';
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
          IconButton(
            onPressed: () => showPicker(),
            icon: Icon(Icons.image_search),
          ),
          Image.network(widget.todo.imagePath),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var path;
          if (_image != null) {
            print('save pressed');
            _key.currentState!.validate();
            UploadTask task =
                firebaseStorage.ref(_image!.path).putFile(_image!);
            path = await (await task).ref.getDownloadURL();

            print(path);
          }

          Todo todo = Todo(
              uid: FirebaseAuth.instance.currentUser!.uid,
              title: _title.text.trim(),
              content: _content.text.trim(),
              imagePath: path ?? widget.todo.imagePath);
          print(todo.toString());
          ListApi().updateTodo(todo: todo, context: context);
        },
        child: Icon(Icons.save),
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
      _image = File(image!.path);
      print(image!.path);
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
      print(image!.path);
    });
  }
}
