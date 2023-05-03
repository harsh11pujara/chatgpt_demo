import 'package:chatgpt_demo/chat_gpt.dart';
import 'package:chatgpt_demo/fetch_apikey.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? apiKey = "";

  Future<void> getApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString("api_key");
    setState(() {
      print("fetched api key" + apiKey.toString());
      print("lenght "+apiKey.toString().length.toString());
    });
  }

  @override
  void initState() {
    getApiKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (apiKey != "" && apiKey != null) {
      return ChatGPTScreen(apiKey: apiKey.toString(),);
    } else {
      return FetchAPIKey();
    }
  }
}
