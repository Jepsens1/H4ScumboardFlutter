import 'dart:convert';
import 'package:http/http.dart';
import 'package:my_app/BoardListObject.dart';

class ApiHandler {
  Future<bool> Register(String username, String password) async {
    Response response = await post(Uri.parse(
        'https://localhost:7252/api/User/RegisterUser?username=$username&password=$password'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> Login(String username, String password) async {
    Response response = await post(Uri.parse(
        'https://localhost:7252/api/User/Login?username=$username&password=$password'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> RemoveTask(int? index) async {
    Response response = await delete(Uri.parse(
        'https://localhost:7252/api/ScrumTask/DeleteScrumTask?id=$index'));
    if (response.statusCode == 200)
      return true;
    else
      return false;
  }

  Future<Response> GetData() async {
    Response response = await get(
        Uri.parse('https://localhost:7252/api/ScrumTask/GetScrumTasks'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<BoardPost> CreateTask(BoardPost task) async {
    Response response = await post(
        Uri.parse("https://localhost:7252/api/ScrumTask/CreateNewScrumTask"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'taskName': task.taskName,
          'taskDescription': task.taskDescription,
          'storyPoints': task.storyPoints,
          'taskState': task.taskState
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> ScrumMap = jsonDecode(response.body);
      return BoardPost.fromJson(ScrumMap);
    } else {
      throw Exception('Failed to Create');
    }
  }

  Future<BoardPost> UpdateTask(BoardPost task) async {
    Response response = await post(
        Uri.parse('https://localhost:7252/api/ScrumTask/UpdateScrumTask'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': task.id,
          'taskName': task.taskName,
          'taskDescription': task.taskDescription,
          'storyPoints': task.storyPoints,
          'taskState': task.taskState
        }));
    if (response.statusCode == 200) {
      Map<String, dynamic> ScrumMap = jsonDecode(response.body);
      return BoardPost.fromJson(ScrumMap);
    } else {
      throw Exception('Failed to Update');
    }
  }
}
