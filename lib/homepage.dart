import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert';
import 'network/cards_data.dart';
import 'network/networkhelper.dart';

bool loading = false;
String _searchResult = '';
String _searchText;
//1 for success -1 for failure
int statusCode = 1;
List<dynamic> cardsFound;
TextEditingController _searchTextController = TextEditingController();
Widget resultsWidget;
NetworkHelper allCardsNetwork = new NetworkHelper(url: overallCardsUrl);

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  Future<void> fetchData() async {
//    var data = await allCardsNetwork.getData();
//    data = jsonDecode(data);
//    _searchResult = data['Basic'][0]['name'];
//  }

  Future<void> fetchSearchData(String card) async {
    NetworkHelper searchCardNetwork = new NetworkHelper(
      url: searchCardsUrl + card,
    );
    dynamic searchResults = await searchCardNetwork.getData();
    if (searchResults == -1) {
      //if search hasn't returned results we remove the list of cards
      buildAlert(context).show();
      if (cardsFound != null) {
        cardsFound.removeRange(0, cardsFound.length);
        print('Cards wiped');
      }
    } else {
      //We remove the previous records
      if (cardsFound != null) {
        cardsFound.removeRange(0, cardsFound.length);
      }
      searchResults = jsonDecode(searchResults);
      cardsFound = searchResults;
    }
  }

  Widget showResults(List<dynamic> cardsFound) {
    List<Widget> results = new List<Widget>();
    for (var card in cardsFound) {
      results.add(
        Card(
          child: ListTile(
            contentPadding: EdgeInsets.all(10),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0),
              child: Image.asset('hs.png'),
            ),
            title: Text(
              card['name'],
              style: TextStyle(
                  color: Color(0xFF5B2416),
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Belwe',
                  fontSize: 20),
            ),
            trailing: Text(
              card['type'],
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              card['cardSet'],
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  fontFamily: 'Belwe'),
            ),
            onTap: () {

              print(card['img'] ?? 'Well no image is provided');
            },
          ),
        ),
      );
    }
    return Flexible(
      child: Align(
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: results,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image(
              image: AssetImage('hs_logo.png'),
              width: 400,
            ),
            Container(
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFE7BF60), width: 4),
                color: Color(0xFF5B2416),
              ),
              padding: EdgeInsets.all(10),
              child: EditableText(
                textAlign: TextAlign.center,
                expands: true,
                minLines: null,
                maxLines: null,
                onChanged: (value) {
                  _searchText = value;
                },
                selectionColor: Colors.purple,
                backgroundCursorColor: Colors.white,
                cursorColor: Color(0xFF335CD7),
                focusNode: FocusNode(),
                style: TextStyle(
                  fontSize: 35,
                  color: Color(0xFFE7BF60),
                  fontFamily: 'Belwe',
                ),
                controller: _searchTextController,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Color(0xFFE7BF60))),
                  child: Text(
                    'Clear search',
                    style: TextStyle(fontFamily: 'Belwe'),
                  ),
                  onPressed: () {
                    _searchTextController.clear();
                    if (cardsFound != null) {
                      cardsFound.removeRange(0, cardsFound.length);
                    }
                    setState(() {});
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Color(0xFFE7BF60))),
                  child: Text(
                    "Search",
                    style: TextStyle(
                      fontFamily: 'Belwe',
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    await fetchSearchData(_searchText);
                    //We make the assign the results widget

                    if (statusCode != -1) {
                      if (cardsFound != null) {
                        resultsWidget = showResults(cardsFound);
                      }
                    }
                    setState(() {
                      loading = false;
                    });
                  },
                ),
              ],
            ),
            CardResults(
              resultsText: _searchResult,
            ),
            Container(
              child: resultsWidget,
            )
          ],
        ),
      ),
    );
  }

  Alert buildAlert(BuildContext context) {
    return Alert(
      context: context,
      title: "No results",
      desc: "Unfortunately your search hasn't returned results",
      image: Image.asset(
        'hs.png',
        scale: 7,
      ),
      style: AlertStyle(
        descStyle: TextStyle(
          fontFamily: 'Belwe',
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF5B2416),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(
            color: Color(0xFFE7BF60),
          ),
        ),
        isCloseButton: false,
        titleStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'Belwe',
            color: Color(0xFFE7BF60),
            fontSize: 30),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Belwe',
            ),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
      ],
    );
  }
}

class CardResults extends StatefulWidget {
  CardResults({this.resultsText});
  final String resultsText;
  @override
  _CardResultsState createState() => _CardResultsState();
}

class _CardResultsState extends State<CardResults> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.resultsText),
    );
  }
}
