import 'dart:convert';

import 'package:http/http.dart';
import 'package:my_app/ApiHandler.dart';
import 'package:my_app/BoardListObject.dart';

class ScrumTaskManager {
  ApiHandler handler = ApiHandler();
  Future<bool> RemoveTask(int? index) {
    return handler.RemoveTask(index);
  }

  Future<BoardPost> UpdateTask(BoardPost task) async {
    return handler.UpdateTask(task);
  }

  Future<BoardPost> CreateTask(BoardPost task) async {
    return handler.CreateTask(task);
  }

  Future<List<BoardPostColumn>> GetData() async {
    Response responseBody = await handler.GetData();
    List<BoardPostColumn> data = [];
    List<BoardPost> tasks = (json.decode(responseBody.body) as List)
        .map((data) => BoardPost.fromJson(data))
        .toList();
    data.add(BoardPostColumn(
        title: 'To do',
        items:
            tasks.where((e) => e.taskState?.toLowerCase() == 'todo').toList()));
    data.add(BoardPostColumn(
        title: 'In Progress',
        items: tasks
            .where((e) => e.taskState?.toLowerCase() == 'in progress')
            .toList()));
    data.add(BoardPostColumn(
        title: 'Done',
        items:
            tasks.where((e) => e.taskState?.toLowerCase() == 'done').toList()));
    return data;
  }
}
