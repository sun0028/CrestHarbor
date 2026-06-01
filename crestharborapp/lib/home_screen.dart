import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'job_service.dart';
import 'notification_screen.dart';
import 'profile_screen.dart'; 
import 'post_job_screen.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool isLoggedIn;
  final bool isEmployer;
  const HomeScreen({super.key, required this.onRefresh, required this.isLoggedIn, required this.isEmployer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
       title: Row(
  mainAxisSize: MainAxisSize.min, 
  children: [
    
    SizedBox(
      height: 32,
      width: 32,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          // Error builder shows a fallback icon if the image still fails to load
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.waves, color: Color(0xFFf03e3e)),
        ),
      ),
    ),
    const SizedBox(width: 12),
    
    Flexible(
      child: Text(
        "CrestHarbor", 
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w900, 
          color: const Color(0xFFf03e3e),
          fontSize: 22,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),

        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.white70),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationScreen())),
            ),
          if (!isLoggedIn)
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AuthScreen(isEmployerInitial: true, onAuth: onRefresh, forceSignup: true))),
              child: const Text("Post Job", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
              child: Column(children: [
                const Text(
                  "Find your dream job,", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFfff5f0))
                ),
                const Text(
                  "start your career journey", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 28, color: Color(0xFFf03e3e), fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),
                const Text(
                  "Discover opportunities from the world's most innovative companies.", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.white38, fontSize: 14)
                ),
                const SizedBox(height: 40),
                if (!isLoggedIn)
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AuthScreen(isEmployerInitial: false, onAuth: onRefresh, forceSignup: true))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf03e3e), 
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text("Get Started !", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                else if (isEmployer)
                   ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PostJobScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf03e3e), 
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text("Post a New Job +", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Latest Opportunities", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFfff5f0), letterSpacing: -0.5)),
                  Text("RECENTLY POSTED POSITIONS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.2)),
                ],
              )
            )
          ),
          const JobSliverList(limit: 3),
        ],
      ),
    );
  }
}

class JobSliverList extends StatelessWidget {
  final int? limit;
  final String query;
  const JobSliverList({super.key, this.limit, this.query = ""});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: JobService().getJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        var jobs = snapshot.data ?? [];
        if (query.isNotEmpty) jobs = jobs.where((j) => j['title'].toString().toLowerCase().contains(query.toLowerCase())).toList();
        if (limit != null && jobs.length > limit!) jobs = jobs.sublist(0, limit);

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final job = jobs[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => JobDetailScreen(job: job))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: const Color(0xFFf03e3e).withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        height: 48, width: 48, 
                        decoration: BoxDecoration(color: const Color(0xFF050000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), 
                        child: const Center(child: Text("💼", style: TextStyle(fontSize: 20)))
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(job['title'] ?? "Job", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFFfff5f0)), overflow: TextOverflow.ellipsis),
                        Text(job['company_name'] ?? "Company", style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13)),
                      ])),
                    ]),
                    const SizedBox(height: 15),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.location_on, color: Color(0xFFf03e3e), size: 14),
                        const SizedBox(width: 6),
                        Text(job['location']?.toString().toUpperCase() ?? "", style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900)),
                      ]),
                      Text(job['salary_range'] ?? "", style: const TextStyle(color: Color(0xFFf03e3e), fontWeight: FontWeight.w900, fontSize: 17)),
                    ]),
                  ]),
                ),
              );
            }, childCount: jobs.length),
          ),
        );
      },
    );
  }
}