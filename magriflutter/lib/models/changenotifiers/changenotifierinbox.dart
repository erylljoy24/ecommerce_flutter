import 'package:flutter/foundation.dart';
import 'package:magri/models/inbox.dart';

class ChangeNotifierInbox with ChangeNotifier, DiagnosticableTreeMixin {
  List<Inbox> inbox = [];

  List<Inbox>? get all => inbox;

  void addInbox(Inbox inbx) {
    inbox.insert(0, inbx); // Add at the beginning of list
    notifyListeners();
  }

  void setInbox(List<Inbox> inboxes) {
    inbox = inboxes;
    notifyListeners();
  }

  void sortInbox(Inbox inbx, int index) {
    inbox.removeAt(index); // Remove from list
    inbox.insert(0, inbx); // Add at the beginning of list
    notifyListeners();
  }

  void getInboxes() async {
    List<Inbox> inboxes = await fetchInbox();
    setInbox(inboxes);
    // fetchInbox().then((dataItems) {
    //   if (dataItems == null) {
    //     return;
    //   }
    //   if (dataItems.length > 0) {
    //     inbox.clear();
    //     dataItems.forEach((item) {
    //       inbox.add(Inbox.fromMap(item));
    //       notifyListeners();
    //     });
    //   }
    // });
  }
}
