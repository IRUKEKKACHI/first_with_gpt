// Message
class Message {
  late final String role;
  late final String content;

  Message({
    required this.role,
    required this.content,
  });

  Message.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['role'] = role;
    data['content'] = content;
    return data;
  }

  Map<String, String> toMap() {
    return {'role': role, 'content': content};
  }

  Message copyWith({String? role, String? content}) {
    return Message(role: role ?? this.role, content: content ?? this.content);
  }
}

// ChatCompletionModel
class ChatCompletionModel {
  late final String model;
  late final List<Message> messages;
  late final bool stream;

  ChatCompletionModel({
    required this.model,
    required this.messages,
    required this.stream,
  });

  ChatCompletionModel.fromJson(Map<String, dynamic> json) {
    model = json['model'];
    messages =
        List.from(json['messages']).map((e) => Message.fromJson(e)).toList();
    stream = json[stream];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['model'] = model;
    data['messages'] = messages.map((e) => e.toJson()).toList();
    data['stream'] = stream;
    return data;
  }
}
