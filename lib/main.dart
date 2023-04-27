import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

void main() {
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
  OpenAI? openAI;
  TextEditingController msgController = TextEditingController();
  List<Widget> chats = [];

  @override
  void initState() {
    openAI = OpenAI.instance.build(token: "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");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(child: ListView.builder(reverse: true,itemCount: chats.length,itemBuilder: (context, index) {
              return chats[index];
            },)),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              padding: EdgeInsets.symmetric(horizontal: 10,),
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: TextField(
                controller: msgController,
                decoration: InputDecoration(
                    hintText: "Ask Chat GPT",
                    suffixIcon: IconButton(
                      onPressed: () {
                        sendMessage(msg: msgController.text);
                      },
                      icon: const Icon(Icons.send_sharp),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget chatTile({required String msg,required String sender}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: sender == "bot" ? Colors.blue : Colors.blueGrey,
                shape: BoxShape.circle),
            child: Center(
                child: Text(sender[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)))),
        Expanded(child: Text(msg, softWrap: true))
      ],
    );
  }

  sendMessage({required String msg}){
    chats.insert(0, chatTile(msg: msg, sender: "user"));
    setState(() {
      getChatGPTData();
      msgController.clear();
    });
  }

  getChatGPTData(){
    var request = CompleteText(prompt: msgController.text, model: kTranslateModelV3 , maxTokens: 200);
    openAI!.onCompleteStream(request: request).listen((event) {
      chats.insert(0, chatTile(msg: event!.choices[0].text, sender: "bot"));
      chats.toSet().toList();
      setState(() {});
    });
  }
}
