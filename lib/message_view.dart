import 'package:flutter/material.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  static const routeName = '/message';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('APP ĐỈNH NHẤT THẾ GIỚI')),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Text(
              args.toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
