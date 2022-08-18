import 'dart:async';
import 'package:magri/services/base_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final String columnId = 'id';
final String columnInboxId = 'inbox_id';
final String columnUser = 'user';
final String columnMessages = 'messages';
final String columnTime = 'time';
final String columnTimestamp = 'timestamp';

class Inbox {
  int? id;
  int? inboxId;
  User? user;
  String? messages;
  String? time;
  int? timestamp;

  Inbox(this.id, this.inboxId, this.user, this.messages, this.time,
      this.timestamp);

  Inbox.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    inboxId = map[columnInboxId];
    if (map[columnUser] != null) {
      user = User.fromMap(map[columnUser]);
    }
    messages = map[columnMessages];
    time = map[columnTime] ?? '';
    id = map[columnTimestamp];
  }

  Inbox.fromJson(Map<String, dynamic> json)
      : id = json[columnTimestamp],
        inboxId = json[columnInboxId],
        user =
            (json[columnUser]) == null ? null : User.fromMap(json[columnUser]),
        messages = json[columnMessages],
        time = json[columnTime] ?? '';
}

Future<List<Inbox>> fetchInbox() async {
  var data = await BaseClient().get('/inbox');

  List<Inbox> inbox = (data as List).map((i) => Inbox.fromJson(i)).toList();

  return inbox;
}

// Future<List<dynamic>?> fetchInbox() async {
//   final SharedPreferences prefs = await _prefs;
//   String? token = await prefs.getString('token');

//   var url = Constants.getInbox;

//   final uri = Uri.parse(url);

//   try {
//     var bearerToken = 'Bearer ' + token.toString();
//     var result = await http.get(uri, headers: <String, String>{
//       'Accept': 'application/json',
//       'Authorization': bearerToken
//     });

//     Map<String, dynamic>? map = json.decode(result.body);
//     print(url + result.statusCode.toString());

//     if (result.statusCode == 200) {
//       return map!['data'];
//     } else {}
//   } catch (e) {
//     print('Error: ' + e.toString());
//   }

//   return null;
// }
