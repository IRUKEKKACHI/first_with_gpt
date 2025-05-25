import 'package:flutter/material.dart';

void main() {
  runApp(FirstWithGPT());
}

class FirstWithGPT extends StatelessWidget {
  const FirstWithGPT({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'First With GPT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController messageTextController = TextEditingController();
  static const String _kStrings = "YdMinS ChatGPT";

  String get _currentString => _kStrings;

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    messageTextController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Card(
                  child: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("히스토리"),
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("설정"),
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("새로운 채팅"),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  //color: Colors.blue,
                  child: ListView.builder(
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      if (index % 2 == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [
                              CircleAvatar(),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('User'),
                                    Text('message'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal,
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("ChatGPT"),
                                Text("message by ChatGPT"),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
              Dismissible(
                key: Key("chat-bar"),
                direction: DismissDirection.startToEnd,
                onDismissed: (d) {
                  if (d == DismissDirection.startToEnd) {
                    //TODO logic onDismissed
                  }
                },
                background: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("New CHat"),
                  ],
                ),
                confirmDismiss: (d) async {
                  if (d == DismissDirection.startToEnd) {
                    //TODO logic confirmDismiss
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(),
                        ),
                        child: TextField(
                          controller: messageTextController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "Message"),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 42,
                      onPressed: () {},
                      icon: Icon(Icons.arrow_circle_up),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
