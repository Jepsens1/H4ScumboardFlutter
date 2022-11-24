class BoardPostColumn {
  String title;
  List<BoardPost> items;

  BoardPostColumn({
    required this.title,
    required this.items,
  });
}

class BoardPost {
  int? id;
  String? taskName;
  String? taskDescription;
  int? storyPoints;
  String? taskState;

  BoardPost(
      {this.id,
      this.taskName,
      this.taskDescription,
      this.storyPoints,
      this.taskState});

  BoardPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taskName = json['taskName'];
    taskDescription = json['taskDescription'];
    storyPoints = json['storyPoints'];
    taskState = json['taskState'];
  }
}
