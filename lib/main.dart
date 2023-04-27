import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
  bool init = true;
  TextEditingController msgController = TextEditingController();
  List<Widget> chats = [];

  @override
  void initState() {
    /// INSERT API KEY ///
    openAI = OpenAI.instance.build(token: dotenv.env["API_KEY"], baseOption: HttpSetup(receiveTimeout: 60000));
    getChatGPTData(question: "init");
    super.initState();
  }

  @override
  void dispose() {
    openAI!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF292F3F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Personal GPT",
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    chats.clear();
                  });
                },
                child: Text(
                  "Clear",
                  style: GoogleFonts.montserrat(color: Colors.white),
                ))
          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: true,
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return chats[index];
                },
              )),
              Container(
                margin: const EdgeInsets.only(top: 2, bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                height: 55,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: TextField(
                    style: GoogleFonts.montserrat(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w400),
                    controller: msgController,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: Colors.white.withOpacity(0.4),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.25),
                        hintText: "Ask Chat GPT",
                        hintStyle: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.6)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: Colors.black.withOpacity(0.25))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: Colors.black.withOpacity(0.25))),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (msgController.text != "") {
                              sendMessage(msg: msgController.text);
                            }
                          },
                          icon: const Icon(Icons.send_sharp, color: Colors.white),
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget chatTile({required String msg, required String sender, bool? hasError}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
          color: sender == "bot" ? const Color(0xFF373E4E) : const Color(0xFF272A35), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(5),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: sender == "bot" ? const Color(0xFF00AC83) : const Color(0xFF837DFF),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(sender[0].toUpperCase(),
                      style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Text(
              msg,
              softWrap: true,
              style:
                  GoogleFonts.montserrat(fontWeight: FontWeight.w400, fontSize: 16, color: hasError == true ? Colors.red[600] : Colors.white),
            ),
          ))
        ],
      ),
    );
  }

  sendMessage({required String msg}) {
    chats.insert(0, chatTile(msg: msg, sender: "user"));
    setState(() {
      getChatGPTData(question: msgController.text.trim());
      msgController.clear();
    });
  }

  getChatGPTData({required String question}) {
    var request = CompleteText(prompt: question, model: kTranslateModelV3, maxTokens: 200);
    openAI!.onCompleteText(request: request).then((value) {
      if (init == false) {
        chats.insert(0, chatTile(msg: value!.choices[0].text.trim(), sender: "bot"));
      }
      setState(() {});
      init = false;
    }).onError((error, stackTrace) {
      if (init == false) {
        chats.insert(0, chatTile(msg: "An error occurred, please ask again", sender: "bot", hasError: true));
      }
      setState(() {});
      init = false;
    });
  }
}
