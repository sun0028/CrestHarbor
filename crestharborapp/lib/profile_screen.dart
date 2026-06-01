import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_service.dart';


class ProfileScreen extends StatefulWidget {
  final VoidCallback onStatusChange;
  const ProfileScreen({super.key, required this.onStatusChange});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Guest";
  String email = "";
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedIn = prefs.getString('token') != null;
      name = prefs.getString('username') ?? "Guest";
      email = prefs.getString('email') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_outlined, size: 80, color: Colors.white10),
              const SizedBox(height: 20),
              const Text("Secure Portal Entry",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFfff5f0))),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => AuthScreen(isEmployerInitial: false, onAuth: widget.onStatusChange))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf03e3e),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SIGN IN TO CRESTHARBOR",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("ACCOUNT SETTINGS",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionCard("EDIT PROFILE", [
            _buildInputField("USERNAME", name),
            _buildInputField("EMAIL", email),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Color(0xFF161616), content: Text("Profile updates are handled via Web Dashboard")));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf03e3e),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("SAVE CHANGES",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 30),
          _buildSectionCard("SECURITY & PRIVACY", [
            _buildInputField("OLD PASSWORD*", ""),
            _buildInputField("NEW PASSWORD*", ""),
            _buildInputField("CONFIRM PASSWORD*", ""),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("UPDATE PASSWORD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await p.clear();
              widget.onStatusChange();
            },
            child: const Text("SIGN OUT OF PLATFORM",
                style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 25),
        ...children,
      ]),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: TextEditingController(text: value),
          style: const TextStyle(color: Color(0xFFfff5f0), fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0a0a0a),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ]),
    );
  }
}


class AuthScreen extends StatefulWidget {
  final bool isEmployerInitial;
  final VoidCallback onAuth;
  final bool forceSignup;

  const AuthScreen({super.key, required this.isEmployerInitial, required this.onAuth, this.forceSignup = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLoginMode;
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isLoginMode = !widget.forceSignup;
  }

  void _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

   
    if (_user.text.trim().isEmpty || _pass.text.trim().isEmpty) {
      messenger.showSnackBar(
          const SnackBar(backgroundColor: Color(0xFF161616), content: Text("Username and Password are required.")));
      return;
    }
    if (!isLoginMode && _email.text.trim().isEmpty) {
      messenger.showSnackBar(
          const SnackBar(backgroundColor: Color(0xFF161616), content: Text("Please enter a valid email address.")));
      return;
    }

    setState(() => loading = true);

    bool success = isLoginMode
        ? await JobService().login(_user.text.trim(), _pass.text.trim())
        : await JobService().register(_user.text.trim(), _email.text.trim(), _pass.text.trim(), widget.isEmployerInitial);

    if (success && !isLoginMode) success = await JobService().login(_user.text.trim(), _pass.text.trim());

    if (!mounted) return;
    setState(() => loading = false);

    if (success) {
      widget.onAuth();
      navigator.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(backgroundColor: Color(0xFF161616), content: Text("Action Failed. Check your credentials.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isLoginMode ? "Welcome Back" : "Create Account",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFfff5f0))),
            const SizedBox(height: 8),
            Text(isLoginMode ? "Enter your credentials." : "Join the CrestHarbor professional network.",
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),
            _authField("USERNAME", _user),
            if (!isLoginMode) _authField("EMAIL ADDRESS", _email),
            _authField("PASSWORD", _pass, isPass: true),
            const SizedBox(height: 30),
            loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFf03e3e)))
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf03e3e),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: Text(isLoginMode ? "LOGIN" : "SIGN UP",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
            if (!widget.forceSignup)
              Center(
                  child: TextButton(
                onPressed: () => setState(() => isLoginMode = !isLoginMode),
                child: Text(isLoginMode ? "NEW HERE? REGISTER" : "ALREADY HAVE AN ACCOUNT? LOGIN",
                    style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
              )),
          ],
        ),
      ),
    );
  }

  Widget _authField(String label, TextEditingController controller, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPass,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF161616),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
        ),
      ]),
    );
  }
}