import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartialSearch extends StatefulWidget {
  final String? placeholder;
  final Color? color;
  final void Function(String)? callbackSubmitted;
  PartialSearch({this.placeholder, this.color, this.callbackSubmitted});
  @override
  State<StatefulWidget> createState() => new _PartialSearchState();
}

class _PartialSearchState extends State<PartialSearch> {
  final _searchController = TextEditingController();

  FocusNode _searchFocus = new FocusNode();

  @override
  void initState() {
    super.initState();

    _searchFocus.addListener(_onFocusChange);
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocus.dispose();
  }

  void _onFocusChange() {
    // Open modal
    // if (_searchFocus.hasFocus) {
    //   setState(() {
    //     _searchEnable = true;
    //   });
    // }
    debugPrint("Focus: " + _searchFocus.hasFocus.toString());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      decoration: BoxDecoration(
        color: widget.color != null ? widget.color : null,
        //color: Colors.grey[100],
        // border: Border.all(color: Colors.green, width: 0.5),
      ),
      padding: EdgeInsets.all(10),
      // focusNode: _searchFocus,
      controller: _searchController,
      //backgroundColor: Colors.white,
      // onSuffixTap: () {
      //   widget.callbackSubmitted('');
      //   _searchController.text = '';
      //   // print('onSuffixTap');
      // },
      onChanged: (value) {
        print("The text has changed to: " + value);
        if (value != '') {
        } else {
          setState(() {
            // _searchResults.clear();
            //_isShowResult = false;
          });
        }

        if (value == '') {
          widget.callbackSubmitted!(value);
        }
      },
      onSubmitted: (value) {
        if (value != '') {
          setState(() {
            // _isShowResult = true;
            // _isLoading = true;
          });
          //search(value);
          print("Submitted text: " + value);
          widget.callbackSubmitted!(value);
        }
      },
      placeholder: widget.placeholder,
    );
  }
}
