import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/todo.dart';

class ListApi {
  late final CollectionReference db;
  late List<DocumentSnapshot> documentList;

  ListApi() {
    db = FirebaseFirestore.instance.collection('todo');
  }

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
    await db.doc(todo.id).update(todo.toJSON()).catchError((onError) {
      print(onError.toString());
    });
  }

  void deleteTodo({required Todo todo, required BuildContext context}) async {
    await db.doc(todo.id).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('TODO deleted!!'),
      ));
    }).catchError((onError) {
      print(onError);
    });
  }

  getFirstTodo() {
    addDocumentList();
    return db.limit(10).snapshots();
  }

  getNextTodo() async {
    updateDocumentList();
    return db
        .limit(10)
        .startAfterDocument(documentList[documentList.length - 1])
        .snapshots();
  }

  void addDocumentList() async {
    try {
      documentList = (await db.limit(10).get()).docs;
    } catch (e) {
      print(e.toString());
    }
  }

  void updateDocumentList() async {
    try {
      List<DocumentSnapshot> newDocumentList = (await db
              .limit(10)
              .startAfterDocument(documentList[documentList.length - 1])
              .get())
          .docs;
      documentList.addAll(newDocumentList);
    } catch (e) {
      print(e.toString());
    }
  }
}
