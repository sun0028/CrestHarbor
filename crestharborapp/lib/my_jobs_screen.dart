import 'package:flutter/material.dart';
import 'job_service.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});
  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late Future<List<dynamic>> _myAppsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = JobService().getMyApplications();
    setState(() {
      _myAppsFuture = data;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTED': return Colors.greenAccent;
      case 'REJECTED': return Colors.redAccent;
      case 'SHORTLISTED': return Colors.blueAccent;
      default: return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("MY APPLICATIONS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFFfff5f0))),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _myAppsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFf03e3e)));
          }
          final apps = snapshot.data ?? [];

          return Column(
            children: [
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                decoration: const BoxDecoration(
                  color: Color(0xFF111111), 
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text("JOB TITLE", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                    Expanded(child: Text("COMPANY", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                    Text("STATUS", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ),

              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: apps.length,
                  itemBuilder: (context, i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616), 
                        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                        
                        borderRadius: i == apps.length - 1 
                          ? const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)) 
                          : BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          
                          Expanded(
                            flex: 2,
                            child: Text(
                              apps[i]['job_title'] ?? "Position",
                              style: const TextStyle(color: Color(0xFFfff5f0), fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          
                          Expanded(
                            child: Text(
                              apps[i]['company_name'] ?? "Artify",
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(apps[i]['status']).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStatusColor(apps[i]['status']).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              apps[i]['status'].toString().toUpperCase(),
                              style: TextStyle(color: _getStatusColor(apps[i]['status']), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
