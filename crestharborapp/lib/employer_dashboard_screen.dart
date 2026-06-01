import 'package:flutter/material.dart';
import 'job_service.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});
  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  late Future<List<dynamic>> _dashFuture;

  void _load() {
    final data = JobService().getEmployerDashboard();
    setState(() {
      _dashFuture = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.greenAccent;
      case 'Rejected': return Colors.redAccent;
      case 'Shortlisted': return Colors.blueAccent;
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
        title: const Text("Recruiter Dashboard", style: TextStyle(fontWeight: FontWeight.w900))
      ),
      body: RefreshIndicator(
        onRefresh: () async { _load(); await _dashFuture; },
        child: FutureBuilder<List<dynamic>>(
          future: _dashFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFf03e3e)));
            }
            final jobs = snapshot.data ?? [];
            if (jobs.isEmpty) {
              return ListView(children: const [SizedBox(height: 100), Center(child: Text("No jobs posted yet."))]);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: jobs.length,
              itemBuilder: (c, i) => Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(jobs[i]['title'] ?? "Job", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFfff5f0))),
                    const SizedBox(height: 5),
                    Text("${jobs[i]['app_count']} Total Applicants", style: const TextStyle(color: Color(0xFFf03e3e), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white10),
                    const Text("APPLICANTS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1.5)),
                    
                    if (jobs[i]['applicants'] != null)
                      ... (jobs[i]['applicants'] as List).map((app) => Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Text(
                                  app['name'] ?? "User", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFfff5f0))
                                ),
                                Text(app['status'] ?? "Pending", style: TextStyle(color: _getStatusColor(app['status']), fontSize: 11, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
                              child: DropdownButton<String>(
                                underline: const SizedBox(),
                                dropdownColor: const Color(0xFF161616),
                                hint: const Text("Action", style: TextStyle(fontSize: 11, color: Colors.white38)),
                                items: ['Shortlisted', 'Accepted', 'Rejected'].map((s) => DropdownMenuItem(
                                  value: s, 
                                  child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                                )).toList(),
                                onChanged: (val) async {
                                  if (val != null) {
                                    final messenger = ScaffoldMessenger.of(context);
                                    bool ok = await JobService().updateApplicationStatus(app['id'], val);
                                    if (mounted && ok) {
                                      messenger.showSnackBar(SnackBar(content: Text("Applicant $val")));
                                      _load();
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}