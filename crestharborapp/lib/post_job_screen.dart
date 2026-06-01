import 'package:flutter/material.dart';
import 'job_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _salary = TextEditingController();
  final _location = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        title: const Text("Post a Job", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          _input("Job Title", _title),
          _input("Location", _location),
          _input("Salary Range", _salary),
          _input("Description", _desc, lines: 5),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              if (_title.text.isEmpty || _desc.text.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text("Please fill in Title and Description"))
                );
                return;
              }

              Map<String, String> data = {
                'title': _title.text,
                'description': _desc.text,
                'salary_range': _salary.text,
                'location': _location.text,
                'category': 'Tech', 
                'work_type': 'Full-time',
                'location_type': 'Remote',
              };              
              bool ok = await JobService().postJob(data);              
              if (!mounted) return;

              if (ok) {
                messenger.showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green, 
                    content: Text("Job Posted Successfully! ")
                  )
                );
                navigator.pop(); 
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red, 
                    content: Text("Failed to post job. Please try again.")
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf03e3e), 
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            child: const Text("Publish Listing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: lines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, 
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true, 
          fillColor: const Color(0xFF161616),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}