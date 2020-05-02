import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'network/networkhelper.dart';
import 'homepage.dart';

Future<void> main() async{
  await DotEnv().load('.env');
  runApp(MyApp());
}

NetworkHelper searchCardNetwork = new NetworkHelper(
  url: 'https://omgvamp-hearthstone-v1.p.rapidapi.com/cards/search/',
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}
