import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 48),
                        Text(
                          "Hi, I'm Hafiz.\n\nI'm a developer who builds tools, apps, and games, mostly as a way to solve problems I run into or explore things I'm curious about.\nSome of my projects help me with everyday tasks, like managing spending or speeding up translations. Others come from school assignments or personal experiments with game development, AI, and embedded systems.\n\nI also enjoy translating Japanese drama CDs and game stories as a hobby. It started as a way to improve my language skills, and it eventually led me to build my own tools for transcription, subtitle editing, and translation assistance.\n\nI don't always aim for polish or perfection. I try to focus on making things work, learning from the process, and slowly improving over time.\nA lot of my work is built in Python, C#, and Java, and I've used frameworks like Unity, Streamlit, and LibGDX depending on what the project calls for.\n\nThis site is where I keep track of everything I've built so far. Thanks for taking the time to check it out.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }
}