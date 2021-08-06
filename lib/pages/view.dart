import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/todo.dart';

class ViewPage extends StatefulWidget {
  ViewPage({Key? key, required this.todo}) : super(key: key);
  final Todo todo;

  @override
  State<StatefulWidget> createState() {
    return ViewPageState();
  }
}

class ViewPageState extends State<ViewPage> {
  final _key = GlobalKey<FormState>();
  var firebaseStorage = FirebaseStorage.instance;

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
                    enabled: false,
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
                    enabled: false,
                    decoration: InputDecoration(labelText: 'Content'),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ],
            ),
          ),
          Image.network(widget.todo.imagePath),
        ],
      ),
    );
  }
}
