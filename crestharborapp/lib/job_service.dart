import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
class JobService {
  static const String baseUrl = "https://sonali028.pythonanywhere.com/api";
  static const String rootUrl = "https://sonali028.pythonanywhere.com";

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access']);
        return await fetchProfile(); 
      }
      return false;
    } catch (e) { return false; }
  }

  Future<bool> register(String u, String e, String p, bool isEmp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': u, 'email': e, 'password': p, 'is_employer': isEmp}),
      );
      return response.statusCode == 201;
    } catch (err) { return false; }
  }

  Future<bool> fetchProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.get(
    Uri.parse('$baseUrl/profile/'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    await prefs.setBool('is_employer', data['is_employer'] ?? false);
    await prefs.setBool('is_seeker', data['is_seeker'] ?? false);
    await prefs.setString('username', data['username'] ?? "User");
    return true;
  }
  return false;
}

  Future<List<dynamic>> getJobs() async {
try {
    final response = await http.get(
      Uri.parse('$baseUrl/jobs/'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'CrestHarborApp/1.0', 
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  } catch (e) {
    return [];
  }

  }



  Future<List<dynamic>> getMyApplications() async {
    final p = await SharedPreferences.getInstance();
    final r = await http.get(Uri.parse('$baseUrl/my-applications/'), headers: {'Authorization': 'Bearer ${p.getString('token')}'});
    return r.statusCode == 200 ? json.decode(r.body) : [];
  }

  Future<List<dynamic>> getEmployerDashboard() async {
    final p = await SharedPreferences.getInstance();
    final r = await http.get(Uri.parse('$baseUrl/employer-dashboard/'), headers: {'Authorization': 'Bearer ${p.getString('token')}'});
    return r.statusCode == 200 ? json.decode(r.body) : [];
  }

  Future<bool> updateApplicationStatus(int id, String status) async {
  final p = await SharedPreferences.getInstance();
  final token = p.getString('token');
  
  final r = await http.post(
    Uri.parse('$baseUrl/application/$id/status/'), 
    headers: {
      'Authorization': 'Bearer $token', 
      'Content-Type': 'application/json'
    },
    body: jsonEncode({'status': status}),
  );
  return r.statusCode == 200;
}

  Future<bool> applyToJob(int jobId, String cover, String? filePath) async {
   final prefs = await SharedPreferences.getInstance();
   final token = prefs.getString('token');
  
   if (token == null) return false;
   try {
    var request = http.MultipartRequest('POST', Uri.parse('$rootUrl/job/$jobId/apply/'));
    
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json', 
    });

    request.fields['cover_letter'] = cover;

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('resume', filePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode == 201 || response.statusCode == 200;
  } 
  catch (e) {
    return false;
  }
 }

    

  Future<bool> postJob(Map<String, String> data) async {
    final p = await SharedPreferences.getInstance();
    final r = await http.post(Uri.parse('$rootUrl/employer/post-job/'), 
      headers: {'Authorization': 'Bearer ${p.getString('token')}', 'Content-Type': 'application/json'},
      body: jsonEncode(data));
    return r.statusCode == 200 || r.statusCode == 302;
  }

  Future<List<dynamic>> getNotifications() async {
    final p = await SharedPreferences.getInstance();
    final r = await http.get(Uri.parse('$baseUrl/notifications/'), headers: {'Authorization': 'Bearer ${p.getString('token')}'});
    return r.statusCode == 200 ? json.decode(r.body) : [];
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}