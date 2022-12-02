import 'package:my_app/ApiHandler.dart';

class LoginManager {
  ApiHandler handler = ApiHandler();
  /**
   * Returns a boolean if the api call from is true or false
   */
  Future<bool> Register(String username, String password) async {
    return handler.Register(username, password);
  }
  /**
   * Returns a boolean if the api call from is true or false
   */
  Future<bool> Login(String username, String password) async {
    return handler.Login(username, password);
  }
}
