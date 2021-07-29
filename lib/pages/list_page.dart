import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:todo/api/list_api.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/pages/edit.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final _search = TextEditingController();
  ScrollController controller = ScrollController();
  var listAPI = ListApi();
  final PagingController _pagingController = PagingController(firstPageKey: 1);

  late var stream;

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
          RefreshIndicator(
              child: PagedListView.separated(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Todo>(
                  itemBuilder: (context, todo, index) =>
                      TodoListViewItem(todo: todo),
                  firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                      error: _pagingController.error,
                      onTryAgain: () => _pagingController.refresh()),
                  noItemsFoundIndicatorBuilder: (context) =>
                      EmptyListIndicator(),
                ),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 15,
                ),
              ),
              onRefresh: () => Future.sync(() => _pagingController.refresh()))
        ],
      ));

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      if (pageKey == 1) {
        stream = listAPI.getFirstTodo();
        pageKey = pageKey + 1;
        _pagingController.appendPage(stream, pageKey);
      } else {
        stream = listAPI.getNextTodo();
        _pagingController.appendPage(stream, pageKey);
      }
    });
    // _search.addListener(() {});
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _search.dispose();
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      print("at the end of list");
      listAPI.getNextTodo();
    }
  }

  TodoListViewItem({required Todo todo}) {
    return Row(
      children: [
        Align(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Image.network(todo.imagePath),
          ),
          alignment: Alignment.centerLeft,
        ),
        Align(
          child: Text(
            todo.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          alignment: Alignment.center,
        ),
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditPage(todo: todo)));
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

  EmptyListIndicator() {
    return Text('No items Present');
  }
}
