import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mbg_scaffold.dart';

class OtpVerificationPage extends StatefulWidget {
  final String newEmail;
  const OtpVerificationPage({super.key, required this.newEmail});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final Color _primaryBlue = const Color(0xFF1A237E);
  
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _startSeconds = 300; 
  bool _isTimerActive = true;

  // --- FIX 1: Menambahkan getter _otpCode yang hilang ---
  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) { controller.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  void _startCountdown() {
    if (_timer != null) _timer!.cancel();
    _isTimerActive = true;
    _startSeconds = 300; 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        setState(() {
          _isTimerActive = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _startSeconds--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _resendOtp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Catatan: Idealnya password diteruskan dari page sebelumnya agar tidak "REDACTED"
    final res = await auth.requestChangeEmail(widget.newEmail, "PASSWORD_USER"); 

    if (res['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode baru telah dikirim!"), backgroundColor: Colors.green),
      );
      _startCountdown();
    }
  }

  void _verifyOtp() async {
    if (!_isTimerActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode sudah kedaluwarsa. Silakan kirim ulang."), 
          backgroundColor: Colors.red
        ),
      );
      return;
    }

    if (_otpCode.length < 6) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final res = await auth.verifyChangeEmail(widget.newEmail, _otpCode);

    if (mounted) {
      if (res['status'] == 'success') {
        // --- TAMBAHKAN PESAN BERHASIL DI SINI ---
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Email berhasil diganti!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Agar pesan melayang dan tetap terlihat saat pop
            duration: Duration(seconds: 2),
          ),
        );

        // Tunggu sebentar agar user sempat membaca pesan sebelum halaman tertutup
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context)..pop()..pop(); 
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Verifikasi gagal"), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MbgScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildTextHeader(), // --- FIX 2: Implementasi Header ---
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),

            const SizedBox(height: 30),
            
            Text(
              _isTimerActive ? "Kode berlaku selama ${_formatTime(_startSeconds)}" : "Kode telah kedaluwarsa",
              style: TextStyle(color: _isTimerActive ? Colors.grey : Colors.red, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (!_isTimerActive)
              TextButton(
                onPressed: _resendOtp,
                child: const Text("Kirim Ulang Kode", style: TextStyle(fontWeight: FontWeight.bold)),
              ),

            const Spacer(),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- FIX 2: Implementasi Widget Header ---
  Widget _buildTextHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verifikasi Kode",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _primaryBlue),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            text: "Masukkan 6 digit kode yang dikirim ke ",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            children: [
              TextSpan(
                text: widget.newEmail,
                style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.grey[100],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _primaryBlue, width: 2)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_otpCode.length == 6) _verifyOtp();
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    final auth = Provider.of<AuthProvider>(context);
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: auth.isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("VERIFIKASI SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}