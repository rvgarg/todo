import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:todo/models/todo.dart';

class ListApi {
  late final CollectionReference db;
  late List<DocumentSnapshot> documentList;

  late BehaviorSubject<List<DocumentSnapshot>> todoController;

  ListApi() {
    db = FirebaseFirestore.instance.collection('todo');
    todoController = BehaviorSubject<List<DocumentSnapshot>>();
  }

  Stream<List<DocumentSnapshot>> get todoStream => todoController.stream;

  addTodo({required Todo todo, required BuildContext context}) async {
    await db.add(todo.toJSON()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('TODO added!!'),
      ));
      Navigator.of(context).pop();
    }).catchError((onError) {
      print(onError);
    });
  }

  void updateTodo({required Todo todo, required BuildContext context}) async {
    await db.doc(todo.id).set(todo.toJSON()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('TODO updated!!'),
      ));
      Navigator.of(context).pop();
    }).catchError((onError) {
      print(onError);
    });
  }

  void deleteTodo({required Todo todo, required BuildContext context}) async {
    await db.doc(todo.id).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('TODO deleted!!'),
      ));
      Navigator.of(context).pop();
    }).catchError((onError) {
      print(onError);
    });
  }

  getFirstTodo() async {
    try {
      documentList = (await db.limit(10).get()).docs;
      todoController.sink.add(documentList);
    } on SocketException {
      todoController.sink.addError(SocketException('No Internet!!'));
    } catch (e) {
      todoController.sink.addError(e);
    }
    return todoController.stream;
  }

  getNextTodo() async {
    try {
      List<DocumentSnapshot> newDocumentList = (await db
              .limit(10)
              .startAfterDocument(documentList[documentList.length - 1])
              .get())
          .docs;
      documentList.addAll(newDocumentList);
      todoController.sink.add(documentList);
    } on SocketException {
      todoController.sink.addError(SocketException('No Internet!!'));
    } catch (e) {
      todoController.sink.addError(e);
    }
    return todoStream;
  }
}
