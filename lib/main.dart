import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:first_with_chatgpt/model/open_ai_model.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TextEditingController messageTextController = TextEditingController();
  final List<Message> _historyList = List.empty(growable: true);

  String apiKey = '0909090';
  String streamText = '';

  static const String _kStrings = "YdMinS ChatGPT";

  String get _currentString => _kStrings;

  ScrollController scrollController = ScrollController();
  late Animation<int> _characterCount;
  late AnimationController animationController;

  void _scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    );
  }

  setupAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    _characterCount = StepTween(begin: 0, end: _currentString.length).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
    animationController.addListener(() {
      setState(() {});
    });
    animationController.addStatusListener((staus) {
      if (staus == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          animationController.reverse();
        });
      } else if (staus == AnimationStatus.dismissed) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          animationController.forward();
        });
      }
    });
    animationController.forward();
  }

  Future requestChat(String text) async {
    ChatCompletionModel openAiModel = ChatCompletionModel(
        model: 'gpt-3.5-turbo',
        messages: [
          Message(role: "system", content: "You are a helpful assistant."),
          ..._historyList,
        ],
        stream: false);
    final url = Uri.http("api.openai.com", "/v1/chat/completions");
    final resp = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(openAiModel.toJson()),
    );
    print(resp.body);
    if (resp.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(resp.bodyBytes)) as Map;
      String role = jsonData['choices'][0]['message']['role'];
      String content = jsonData['choices'][0]['message']['content'];
      _historyList.last =
          _historyList.last.copyWith(role: role, content: content);
    }
    setState(() {
      _scrollDown();
    });
  }

  Stream requestChatStream(String text) async* {
    ChatCompletionModel openAiModel = ChatCompletionModel(
        model: "gpt-3.5-turbo",
        messages: [
          Message(role: "system", content: "You are a helpful assistant."),
          ..._historyList,
        ],
        stream: true);

    final url = Uri.http('api.openai.com', '/v1/chat/completions');
    final request = http.Request('POST', url)
      ..headers.addAll(
        {
          "Authorization": "Baerer ${apiKey}",
          "Content-Type": 'application/json; charset=UTF-8',
          'Connection': 'keep-alive',
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate, br',
        },
      );
    request.body = jsonEncode(openAiModel.toJson());

    final resp = await http.Client().send(request);
    final byteStream = resp.stream.asyncExpand(
      (event) => Rx.timer(
        event,
        const Duration(milliseconds: 50),
      ),
    );
    final statusCode = resp.statusCode;
    var respText = '';
    await for (final byte in byteStream) {
      var decode = utf8.decode(byte, allowMalformed: false);
      final strings = decode.split("data: ");
      for (final string in strings) {
        final trimmedString = string.trim();
        if (trimmedString.isNotEmpty && !trimmedString.endsWith('[DONE]')) {
          final map = jsonDecode(trimmedString) as Map;
          final choices = map['choices'] as List;
          final delta = choices[0]['delta'] as Map;
          if (delta['content'] != null) {
            final content = delta['content'] as String;
            respText += content;
            setState(() {
              streamText = respText;
            });
            yield content;
          }
        }
      }
    }

    if (respText.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    setupAnimation();
  }

  @override
  void dispose() {
    messageTextController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future clearChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("새로운 대화 시작"),
        content: Text("신규 대화를 생성하시겠어요?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                messageTextController.clear();
                _historyList.clear();
              });
            },
            child: Text("네"),
          ),
        ],
      ),
    );
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
                          onTap: () {
                            clearChat();
                          },
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
                  child: _historyList.isEmpty
                      ? Center(
                          child: AnimatedBuilder(
                            animation: _characterCount,
                            builder: (BuildContext context, Widget? chi) {
                              String text = _currentString.substring(
                                  0, _characterCount.value);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    text,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.orange[200],
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      : GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: _historyList.length,
                            itemBuilder: (context, index) {
                              if (_historyList[index].role == 'user') {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_historyList[index].role),
                                            Text(_historyList[index].content),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.teal,
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_historyList[index].role),
                                        Text(_historyList[index].content),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        )),
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
                    Text("New Chat"),
                  ],
                ),
                confirmDismiss: (d) async {
                  if (d == DismissDirection.startToEnd) {
                    if (_historyList.isEmpty) return;
                    clearChat();
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
                      onPressed: () async {
                        if (messageTextController.text.isEmpty) {
                          return;
                        }
                        setState(() {
                          _historyList.add(
                            Message(
                              role: "user",
                              content: messageTextController.text.trim(),
                            ),
                          );
                          _historyList.add(
                            Message(
                              role: "assistant",
                              content: "",
                            ),
                          );
                        });
                        try {
                          // await requestChat(messageTextController.text.trim());
                          var text = '';
                          final stream = requestChatStream(
                              messageTextController.text.trim());
                          await for (final textChunk in stream) {
                            text += textChunk;
                            setState(() {
                              _historyList.last =
                                  _historyList.last.copyWith(content: text);
                              _scrollDown();
                            });
                          }
                          messageTextController.clear();
                          streamText = '';
                        } catch (e) {
                          print(e.toString());
                        }
                      },
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
