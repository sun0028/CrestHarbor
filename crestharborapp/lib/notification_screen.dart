import 'package:flutter/material.dart';
import 'job_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF050000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "NOTIFICATIONS",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.1),
            radius: 2.8,
            colors: [Color(0xFF3a0a0a), Color(0xFF050000)],
            stops: [0.0, 0.7],
          ),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: JobService().getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFf03e3e)));
            }
            
            final notes = snapshot.data ?? [];
            
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.notifications_off_outlined, size: 60, color: Colors.white10),
                    SizedBox(height: 16),
                    Text(
                      "No new alerts yet.",
                      style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
              itemCount: notes.length,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      height: 8, width: 8,
                      decoration: const BoxDecoration(color: Color(0xFFf03e3e), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notes[i]['message'] ?? "",
                            style: const TextStyle(
                              color: Color(0xFFfff5f0), 
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "JUST NOW", 
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
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