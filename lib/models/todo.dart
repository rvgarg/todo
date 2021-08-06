class Todo {
  String? id;
  final String title;
  final String content;
  final String imagePath;
  final String uid;

  Todo(
      {required this.title,
      required this.content,
      required this.imagePath,
      required this.uid});

  toJSON() {
    return {
      'title': this.title,
      'content': this.content,
      'imagePath': this.imagePath,
      'uid': this.uid
    };
  }

  factory Todo.fromJSON(Map<String, dynamic> json, String id) {
    Todo todo = Todo(
        title: json['title'],
        content: json['content'],
        uid: json['uid'],
        imagePath: json['imagePath']);
    todo.id = id;
    return todo;
  }
}
