class Todo {
  String? id;
  final String title;
  final String content;
  final String imagePath;

  Todo({required this.title, required this.content, required this.imagePath});

  toJSON() {
    return {
      'title': this.title,
      'content': this.content,
      'imagePath': this.imagePath
    };
  }

  factory Todo.fromJSON(Map<String, dynamic> json) {
    return Todo(
        title: json['title'], content: json['content'], imagePath: json['imagePath']);
  }
}
