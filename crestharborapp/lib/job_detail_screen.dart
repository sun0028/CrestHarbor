import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'job_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _hasApplied = false;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    final apps = await JobService().getMyApplications();
    if (mounted) {
      setState(() {
        _hasApplied = apps.any((app) => app['job_title'] == widget.job['title']);
        _isLoading = false;
      });
    }
  }

  void _showApplyModal(BuildContext context) {
    final TextEditingController coverController = TextEditingController();
    String? filePath;
    String fileName = "No file selected";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            left: 25, right: 25, top: 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Complete Application",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFfff5f0)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: coverController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Cover letter...",
                  filled: true,
                  fillColor: const Color(0xFF0a0a0a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  const XTypeGroup typeGroup = XTypeGroup(label: 'PDFs', extensions: <String>['pdf']);
                  final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                  if (file != null) {
                    setModalState(() {
                      filePath = file.path;
                      fileName = file.name;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0a0a0a),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Color(0xFFf03e3e), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(fileName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ),
                      const Text("ATTACH",
                          style: TextStyle(color: Color(0xFFf03e3e), fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ✅ CONFIRM APPLICATION button — inside StatefulBuilder so it has access to filePath and coverController
              ElevatedButton(
                onPressed: () async {
                  if (filePath == null) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text("Please attach a resume PDF")),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(this.context);

                  // Show loading dialog
                  showDialog(
                    context: this.context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFFf03e3e)),
                    ),
                  );

                  try {
                    final jobId = widget.job['id'];

                    bool ok = await JobService().applyToJob(
                      jobId,
                      coverController.text.isEmpty ? "Applied via Mobile" : coverController.text,
                      filePath,
                    );

                    // Close loading dialog
                    if (mounted) Navigator.of(this.context).pop();

                    if (ok) {
                      if (mounted) setState(() => _hasApplied = true);
                      // Close the modal
                      if (mounted) Navigator.of(this.context).pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Application Sent Successfully! ✓"),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Server error. Check your connection and try again."),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) Navigator.of(this.context).pop(); // close loading dialog
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.orange,
                        content: Text("Error: ${e.toString()}"),
                        duration: const Duration(seconds: 6),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf03e3e),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("CONFIRM APPLICATION", style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey, size: 20),
        title: const Text(
          "BACK TO EXPLORE",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white24),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFf03e3e)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFf03e3e).withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.job['category']?.toString().toUpperCase() ?? "TECH",
                                style: const TextStyle(color: Color(0xFFf03e3e), fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "• ${widget.job['work_type']?.toString().toUpperCase() ?? 'FULL-TIME'}",
                              style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.job['title'] ?? "",
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFfff5f0), letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.job['company_name'] ?? "",
                          style: const TextStyle(fontSize: 16, color: Color(0xFFf03e3e), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _headerStat("📍", widget.job['location'] ?? "Remote"),
                            const SizedBox(width: 20),
                            _headerStat("💰", widget.job['salary_range'] ?? "Negotiable"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ABOUT THE POSITION",
                          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.job['description'] ?? "",
                          maxLines: _isExpanded ? null : 4,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isExpanded = !_isExpanded),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _isExpanded ? "Read Less ↑" : "Read More ↓",
                              style: const TextStyle(
                                  color: Color(0xFFf03e3e), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("COMPANY INSIGHT",
                                  style: TextStyle(
                                      color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1)),
                              const SizedBox(height: 10),
                              Text(widget.job['company_name'] ?? "",
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFfff5f0))),
                              const SizedBox(height: 8),
                              const Text(
                                "Leading organization focused on digital transformation and technical excellence.",
                                style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ✅ APPLY FOR JOB button — correctly calls _showApplyModal
                        _hasApplied
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                                ),
                                child: const Center(
                                  child: Text(" APPLICATION SUBMITTED",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 1)),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () => _showApplyModal(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFf03e3e),
                                  minimumSize: const Size(double.infinity, 54),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("APPLY FOR JOB ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _headerStat(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}