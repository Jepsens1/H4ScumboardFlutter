import 'dart:convert';

import 'package:http/http.dart';
import 'package:my_app/ApiHandler.dart';
import 'package:my_app/BoardListObject.dart';

class ScrumTaskManager {
  ApiHandler handler = ApiHandler();

  /**
   * Returns true or false depending on api delete was successful
   */
  Future<bool> RemoveTask(int? index) {
    return handler.RemoveTask(index);
  }
  /**
   * Returns the updated BoardPost object from api
   */
  Future<BoardPost> UpdateTask(BoardPost task) async {
    return handler.UpdateTask(task);
  }
  /**
   * Returns the newly created BoardPost Object
   */
  Future<BoardPost> CreateTask(BoardPost task) async {
    return handler.CreateTask(task);
  }
  /**
   * Gets a response from ApiHandler and maps json data in to List<BoardPostColumn> and returns list
   */
  Future<List<BoardPostColumn>> GetData() async {
    Response responseBody = await handler.GetData();
    List<BoardPostColumn> data = [];
    //Takes the response body and json decodes it, And foreach object in the response body, calls BoardPost.fromJson.
    List<BoardPost> tasks = (json.decode(responseBody.body) as List)
        .map((data) => BoardPost.fromJson(data))
        .toList();

    //Adds 3 different BoardPostColumns with different titles
    //Each BoardPostColumn only gets the List<BoardPost> where the TaskState is equal to the BoardPostColumn title
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
