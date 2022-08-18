import 'package:flutter/foundation.dart';
import 'package:magri/models/chat_message.dart';

class ChangeNotifierChatOrder with ChangeNotifier, DiagnosticableTreeMixin {
  List<int?> _orderIds = [];
  List<String> _statuses = [];

  List<ChatMessage> _messages = [];

  void setOrderStatus(int? orderId, String status) {
    // If no orderId yet then add it
    if (!_orderIds.asMap().containsKey(orderId)) {
      _orderIds.add(orderId);
    }

    // Get the key of orderId first
    int index = getOrderIdKey(orderId);

    if (_statuses.asMap().containsKey(index)) {
      _statuses[index] = status;
    } else {
      _statuses.add(status);
    }

    print('setOrderStatus:' + status);

    notifyListeners();
  }

  String getOrderStatus(int? orderId) {
    // Get the key of orderId first
    int index = getOrderIdKey(orderId);

    // if (_statuses.asMap().containsKey(orderId)) {
    if (_statuses.asMap().containsKey(index)) {
      print('Exists' + _statuses[index]);
      return _statuses[index];
      //return _statuses[orderId];
    } else {
      return '';
    }
  }

  int getOrderIdKey(int? orderId) {
    return _orderIds.indexOf(orderId);
  }

  void setChatMessage(ChatMessage message) {
    _messages.add(message);

    notifyListeners();
  }

  List<ChatMessage> getChatMessages() {
    return _messages;
  }
}
