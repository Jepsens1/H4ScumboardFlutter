import 'package:my_app/screens/ApiHandler.dart';

class LoginManager {
  ApiHandler handler = ApiHandler();
  Future<bool> Register(String username, String password) async {
    return handler.Register(username, password);
  }

  Future<bool> Login(String username, String password) async {
    return handler.Login(username, password);
  }
}
