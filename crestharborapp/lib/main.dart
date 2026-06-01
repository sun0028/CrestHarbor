import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'home_screen.dart';
import 'find_jobs_screen.dart';
import 'my_jobs_screen.dart';
import 'employer_dashboard_screen.dart';
import 'profile_screen.dart';
import 'dart:io';
import 'job_service.dart'; 
void main() {
  HttpOverrides.global = MyHttpOverrides(); 
  runApp(const CrestHarborApp());
}

class CrestHarborApp extends StatelessWidget {
  const CrestHarborApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
      ),

      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainNavigationHolder()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment.center, radius: 1.5, colors: [Color(0xFF3a0a0a), Color(0xFF050000)]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 20),
              const Text("CrestHarbor", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFf03e3e), letterSpacing: -1)),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Color(0xFFf03e3e), strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});
  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isEmployer = false;

  @override
  void initState() { super.initState(); _checkStatus(); }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('token') != null;
      _isEmployer = prefs.getBool('is_employer') ?? false;
    });
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(onRefresh: _checkStatus, isLoggedIn: _isLoggedIn, isEmployer: _isEmployer),
      const FindJobsScreen(),
      if (_isLoggedIn) (_isEmployer ? const EmployerDashboardScreen() : const MyJobsScreen()),
      ProfileScreen(onStatusChange: _checkStatus),
    ];
  }

  @override
  Widget build(BuildContext context) {
    
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _selectedIndex = 0);
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -1.1), focal: Alignment(0, -0.9), radius: 2.8, colors: [Color(0xFF3a0a0a), Color(0xFF050000)], stops: [0.0, 0.7]),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex >= _buildScreens().length ? 0 : _selectedIndex,
              children: _buildScreens(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex >= 3 ? (_isLoggedIn ? 2 : 2) : _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            backgroundColor: const Color(0xFF0a0a0a),
            selectedItemColor: const Color(0xFFf03e3e),
            unselectedItemColor: Colors.grey[600],
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
              const BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find Jobs"),
              if (_isLoggedIn) BottomNavigationBarItem(icon: Icon(_isEmployer ? Icons.dashboard : Icons.work_outline), label: _isEmployer ? "Dashboard" : "My Jobs"),
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}