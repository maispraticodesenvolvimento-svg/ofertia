import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminClientsScreen extends StatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  State<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends State<AdminClientsScreen> {
  late Future<List<Map<String, dynamic>>> _users;

  @override
  void initState() {
    super.initState();
    _users = ApiClient().getUsers(role: 'buyer');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _users,
        builder: (context, snapshot) {
          final users = snapshot.data ?? const <Map<String, dynamic>>[];
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text('Clientes', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            Text('Contas de comprador registradas no sistema.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
            else if (users.isEmpty)
              _empty('Ainda não há clientes cadastrados.', Icons.people_outline)
            else
              ...users.map(_userCard),
          ]);
        },
      );

  Widget _userCard(Map<String, dynamic> user) {
    final email = user['email']?.toString() ?? 'E-mail não informado';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
      child: Row(children: [
        CircleAvatar(backgroundColor: AppColors.primarySurface, child: Text(email.isNotEmpty ? email[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(email, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.grey900)),
          Text('UID: ${user['uid']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
        ])),
        Text('Comprador', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
      ]),
    );
  }

  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, size: 34, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
