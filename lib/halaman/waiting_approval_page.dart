// lib/halaman/waiting_approval_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class WaitingApprovalPage extends StatelessWidget {
  const WaitingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                "Akun Sedang Diverifikasi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Mohon tunggu, Admin Dapur sedang memeriksa dokumen SK dan NPSN sekolah Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.refreshApprovalStatus();
                  if (authProvider.isApproved) {
                    // Jika sudah disetujui, pindah ke dashboard
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/dashboard-operator',
                      );
                    }
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Cek Status Sekarang"),
              ),
              TextButton(
                onPressed: () => authProvider.logout(),
                child: const Text("Keluar / Login Ulang"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
