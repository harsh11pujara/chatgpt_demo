import 'package:chatgpt_demo/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class FetchAPIKey extends StatelessWidget {
  FetchAPIKey({Key? key}) : super(key: key);
  final TextEditingController apiKey = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF292F3F),
        appBar: AppBar(elevation: 0,backgroundColor: Colors.transparent,title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    storeData().then((value) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ));
                    });
                  }
                },
                child: const Text(
                  "Proceed",
                  style: TextStyle(color: Colors.white),
                )),
            const SizedBox(
              width: 15,
            )
          ],
        ),),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height-100,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 380,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      validator: (value) {
                        if(value != "" && apiKey.text.trim().toString().length == 51){
                          return null;
                        }
                        else{
                          return "Enter valid API Key";
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      controller: apiKey,
                      decoration: const InputDecoration(
                          label: Text(
                            "API Key",
                            style: TextStyle(color: Colors.white),
                          ),
                          enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.zero)),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  const Text("Get your OpenAI API key from here :", style: TextStyle(color: Colors.white)),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse("https://platform.openai.com/account/api-keys"), mode: LaunchMode.externalApplication);
                      },
                      child: const Text(
                        "https://platform.openai.com/account/api-keys",
                        style: TextStyle(color: Colors.teal),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> storeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("api_key", apiKey.text.trim());
  }
}
