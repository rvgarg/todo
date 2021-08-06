import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/api/list_api.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/pages/edit.dart';
import 'package:todo/pages/view.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final _search = TextEditingController();
  ScrollController controller = ScrollController();
  var listAPI = ListApi();
  StreamController<QuerySnapshot<Map<String, dynamic>>> streamController =
      StreamController<QuerySnapshot<Map<String, dynamic>>>();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            TextFormField(
              controller: _search,
              decoration: InputDecoration(
                labelText: 'Search',
                icon: Icon(Icons.search),
              ),
            ),
            Align(
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed('/add');
                },
              ),
              alignment: Alignment.topRight,
            ),
            StreamBuilder(
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    controller: controller,
                    itemBuilder: (context, index) => TodoListViewItem(
                        todo: Todo.fromJSON(snapshot.data!.docs![index].data(),
                            snapshot.data!.docs![index].id)),
                    itemCount: snapshot.data!.docs.length,
                  );
                }
              },
              stream: streamController.stream,
            )
          ],
        ),
      );

  @override
  void initState() {
    streamController.addStream(listAPI.getFirstTodo());
    // _search.addListener(() {});
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      print("at the end of list");
      setState(() {
        streamController.addStream(listAPI.getNextTodo());
      });
    }
  }

  TodoListViewItem({required Todo todo}) {
    return Stack(
      children: [
        Align(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Image.network(
                  todo.imagePath,
                  scale: 0.5,
                )),
          ),
          alignment: Alignment.centerLeft,
        ),
        Align(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewPage(todo: todo)));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                todo.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          alignment: Alignment.center,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditPage(todo: todo)));
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  listAPI.deleteTodo(todo: todo, context: context);
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        )
      ],
    );
  }

  ErrorIndicator({required error, required void Function() onTryAgain}) {
    return SizedBox(
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 25,
            ),
            onPressed: onTryAgain,
          ),
          Text(error.toString()),
        ],
      ),
    );
  }
}
