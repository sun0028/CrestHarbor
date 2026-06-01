import 'package:flutter/material.dart';
import 'home_screen.dart'; 

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});
  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}
class _FindJobsScreenState extends State<FindJobsScreen> {
  String _q = "";
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("Explore"), bottom: PreferredSize(preferredSize: const Size.fromHeight(60), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(onChanged: (v)=>setState(()=>_q=v), decoration: InputDecoration(hintText: "Search...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: const Color(0xFF161616), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)))))),
    body: CustomScrollView(slivers: [JobSliverList(query: _q)]),
  );
}