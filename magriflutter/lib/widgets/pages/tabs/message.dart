import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magri/models/changenotifiers/changenotifierinbox.dart';
import 'package:magri/models/inbox.dart';
import 'package:magri/models/user.dart';
import 'package:magri/models/notif.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/pages/message/view_chat.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/partial_search.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Message extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MessageState();
}

class _MessageState extends State<Message>
    with
        AutomaticKeepAliveClientMixin<Message>,
        SingleTickerProviderStateMixin<Message> {
  List<Notif> _notifications = [];

  List<Inbox> _inbox = [];

  bool _isLoading = false;
  double progress = 0.2;

  String? _q;

  TabController? _tabController;

  List<Widget> _tabList = [
    Tab(text: 'My Messages'),
    Tab(text: 'Notifications'),
  ];

  // Use this so that the tab wont reload again
  // wantKeepAlive = true
  // with AutomaticKeepAliveClientMixin<Message>
  // super.build(context); // need to call super method. on build()
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabList.length, vsync: this);

    _tabController!.addListener(() {
      print("Selected Index: " + _tabController!.index.toString());
    });

    // fetch();
    // inboxController.getInboxes();
    // https://www.kindacode.com/article/sorting-lists-in-dart/
    // _inbox.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    // _inbox.removeAt(index)
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ChangeNotifierInbox>(context, listen: false).getInboxes();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetch() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    fetchInbox().then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inbox = dataItems;
        // if (dataItems != null) {
        //   dataItems.forEach((item) {
        //     _inbox.add(Inbox.fromMap(item));
        //   });
        // }
        _isLoading = false;
      });
    });
  }

  ListTile _menu(BuildContext context, Inbox inbox, int index, String name,
      String messages, Icon icon,
      {User? chatUser, String? time = ''}) {
    // //User chatUser = User('5', 'John Smith', 'max.xxx@gmail.com',
    //     'https://www.drupal.org/files/user-pictures/picture-2204516-1469808304.png');
    return ListTile(
      // leading: CircleAvatar(
      //   backgroundImage: NetworkImage(image),
      //   backgroundColor: Colors.transparent,
      //   radius: 20,
      // ),
      leading: chatUser == null ? Text('Magri User') : showOnline(chatUser),
      // showOnline
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green[900])),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          Text(messages,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Colors.grey[700])),
        ],
      ),
      onTap: () {
        if (chatUser != null) {
          _navigateChat(chatUser, inbox, index);
        }
      },
      trailing:
          Text(time!, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    );
  }

  _navigateChat(User user, Inbox inbox, int index) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ViewChat(user: user, inbox: inbox, inboxIndex: index)),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        print('result:' + result['email']);

        // print('_navigateChat' + result['token']);
      }
    }
  }

  Widget showSearchInput() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 50.0,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0.0, 0, 0.0),
          child: PartialSearch(
            placeholder: 'Enter Keyword here',
            //color: Colors.white,
            callbackSubmitted: search,
          )),
    );
  }

  Widget showOnline(User chatUser) {
    return Stack(
      children: [
        CircleAvatar(
          // backgroundImage: NetworkImage(
          //     'https://www.drupal.org/files/user-pictures/picture-2204516-1469808304.png'),
          backgroundImage: CachedNetworkImageProvider(chatUser.image!),
          backgroundColor: Colors.transparent,
          radius: 20,
        ),
        Positioned(
          child: Container(
            width: 10,
            height: 10,
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[600], // change to transparent if offline
            ),
          ),
          top: -4,
          right: 0,
        )
      ],
    );
  }

  Widget showSearchButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(29, 10, 29, 10),
        child: Row(children: [
          SizedBox(
              // width: 200,
              width: MediaQuery.of(context).size.width / 1.2,
              child: PartialSearch(
                placeholder: 'Search ...',
                color: Colors.grey[100],
                callbackSubmitted: search,
              )),
        ]));
  }

  void search(String q) {
    setState(() {
      _q = q;
    });

    print('callback: ' + q);

    fetch();
  }

  Widget messages() {
    return _isLoading
        ? SpinKitThreeBounce(
            color: Colors.green,
            size: 30,
          )
        : Container(
            // color: Colors.white,
            color: const Color(0XFFFCFCFC),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<ChangeNotifierInbox>(
                  builder: (context, inbox, child) {
                    return Expanded(
                        child: ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                  color: Colors.grey,
                                ),
                            itemCount: inbox.all!.length,
                            itemBuilder: (context, index) {
                              return _menu(
                                context,
                                inbox.all![index],
                                index,
                                inbox.all![index].user != null
                                    ? inbox.all![index].user!.name!
                                    : '',
                                inbox.all![index].messages!,
                                Icon(Icons.shopping_bag_sharp,
                                    color: Colors.green),
                                chatUser: inbox.all![index].user,
                                time: inbox.all![index].time,
                              );
                            }));
                  },
                ),
                // Expanded(
                //     child: ListView.separated(
                //         separatorBuilder: (context, index) => Divider(
                //               color: Colors.grey,
                //             ),
                //         itemCount: _inbox.length,
                //         itemBuilder: (context, index) {
                //           return _menu(
                //             context,
                //             index,
                //             _inbox[index].user!.name!,
                //             _inbox[index].messages!,
                //             Icon(Icons.shopping_bag_sharp, color: Colors.green),
                //             chatUser: _inbox[index].user,
                //             time: _inbox[index].time,
                //           );
                //         }))
              ],
            ));
  }

  Widget notifications() {
    return _isLoading
        ? SpinKitThreeBounce(
            color: Colors.green,
            size: 30,
          )
        : Container(
            // color: Colors.white,
            color: const Color(0XFFFCFCFC),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                              color: Colors.grey,
                            ),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return Text('');
                          // return _menu(
                          //   context,
                          //   index.all![index],
                          //   index,
                          //   _notifications[index].subject!,
                          //   _notifications[index].text!,
                          //   Icon(Icons.shopping_bag_sharp, color: Colors.green),
                          // );
                        }))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // need to call super method.
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTop(
        context,
        isLogoHidden: true,
        title: 'Messages & Notifications',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(108),
          child: Material(
              // Set the background color of the tab here
              color: Colors.white,
              //elevation: 1,
              shadowColor: Colors.grey,
              child: Column(
                children: [
                  showSearchButton(),
                  Container(
                      margin: EdgeInsets.zero,
                      child: TabBar(
                        indicatorWeight: 5,
                        labelColor: greenColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0XFFFECD4D),
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        onTap: (index) {
                          // Should not used it as it only called when tab options are clicked,
                          // not when user swapped
                        },
                        controller: _tabController,
                        tabs: _tabList,
                      ))
                ],
              )),
        ),
      ),
      // appBar: appBarTop(context, title: 'Messages & Notifications'),
      body: new Container(
        padding: const EdgeInsets.only(top: 28.0),
        child: Stack(children: [
          TabBarView(
            controller: _tabController,
            children: [
              messages(),
              notifications(),
            ],
          ),
        ]),
      ),
    );
  }
}
