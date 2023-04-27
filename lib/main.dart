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
    return Container(
      color: Colors.greenAccent,
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sender),
            const SizedBox(height: 5,),
            Text(msg)
          ],
        )
      ],),
    );
  }

  sendMessage({required String msg}){
    chats.insert(0, chatTile(msg: msg, sender: "user"));
    setState(() {
      msgController.clear();
      getChatGPTData();
    });
  }

  getChatGPTData(){
    var request = CompleteText(prompt: "What is flutter", model: kTranslateModelV3 , maxTokens: 200);
    openAI!.onCompleteStream(request: request).listen((event) { 
      print(event);
    });
  }
}
