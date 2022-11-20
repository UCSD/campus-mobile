import 'package:hive/hive.dart';

//TODO: temporary patch, data storage architecture needs to be redone
class Username
{
  // called in main function on program start
  static void initialize() async {
    await Hive.openBox('username');
  }

  // returns null if there is no username in storage
  static String? get() {
    var usernameBox = Hive.box('username');
    return usernameBox.get('username');
  }

  static void set(String username) {
    var usernameBox = Hive.box('username');
    usernameBox.put('username', username);
  }

  static void delete() {
    var usernameBox = Hive.box('username');
    usernameBox.delete('username');
  }
}