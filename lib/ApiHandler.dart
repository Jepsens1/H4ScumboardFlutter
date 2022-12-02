import 'dart:convert';
import 'package:http/http.dart';
import 'package:my_app/BoardListObject.dart';

class ApiHandler {

//Note that 10.0.2.2 is android emulator ip to point to localhost on pc

  /**
   * Calls a post method to api, returns true is call is succesful
   *
   */
  Future<bool> Register(String username, String password) async {
    Response response = await post(Uri.parse(
        'https://10.0.2.2:7252/api/User/RegisterUser?username=$username&password=$password'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
  /**
   * Calls a post method to api, returns true is call is succesful
   */
  Future<bool> Login(String username, String password) async {
    Response response = await post(Uri.parse(
        'https://10.0.2.2:7252/api/User/Login?username=$username&password=$password'));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }


  /**Calls a delete method to api, returns true is call is succesful
  index parameter is the Scrumtask ID in the database
  Gets the index from selected Scrumtask in ScrumBoard widget
    */
  Future<bool> RemoveTask(int? index) async {
    Response response = await delete(Uri.parse(
        'https://10.0.2.2:7252/api/ScrumTask/DeleteScrumTask?id=$index'));
    if (response.statusCode == 200)
      return true;
    else
      return false;
  }
   /**
    * Calls a get method and returns response, that the ScrumManager class will use to map the data to a list
    *   
    */
  Future<Response> GetData() async {
    Response response = await get(
        Uri.parse('https://10.0.2.2:7252/api/ScrumTask/GetScrumTasks'));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load');
    }
  }
  /**
   *Calls a post method and parses in a BoardPost object into json format
  Returns the newly created BoardPost object, with a ID from database 
  */
  Future<BoardPost> CreateTask(BoardPost task) async {
    Response response = await post(
        Uri.parse("https://10.0.2.2:7252/api/ScrumTask/CreateNewScrumTask"),
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
  /**Calls a post method and parses in a BoardPost object into json format
      Returns the newly updated BoardPost object
  */
  Future<BoardPost> UpdateTask(BoardPost task) async {
    Response response = await post(
        Uri.parse('https://10.0.2.2:7252/api/ScrumTask/UpdateScrumTask'),
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
