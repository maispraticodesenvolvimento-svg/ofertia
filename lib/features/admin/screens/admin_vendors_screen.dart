import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class AdminVendorsScreen extends StatefulWidget {
  const AdminVendorsScreen({super.key});

  @override
  State<AdminVendorsScreen> createState() => _AdminVendorsScreenState();
}

class _AdminVendorsScreenState extends State<AdminVendorsScreen> {
  late Future<List<Map<String, dynamic>>> _vendors;

  @override
  void initState() {
    super.initState();
    _vendors = ApiClient().getUsers(role: 'vendor');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _vendors,
        builder: (context, snapshot) {
          final vendors = snapshot.data ?? const <Map<String, dynamic>>[];
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text('Vendedores', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.grey900)),
            Text('Contas com papel de vendedor no Realtime Database.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _empty(snapshot.error.toString(), Icons.cloud_off_outlined)
            else if (vendors.isEmpty)
              _empty('Ainda não há vendedores cadastrados.', Icons.store_outlined)
            else
              ...vendors.map((vendor) => ListTile(
                tileColor: Colors.white,
                leading: const CircleAvatar(child: Icon(Icons.store_outlined)),
                title: Text(vendor['name']?.toString() ?? vendor['email']?.toString() ?? 'Vendedor'),
                subtitle: Text(vendor['email']?.toString() ?? 'UID: ${vendor['uid']}'),
              )),
          ]);
        },
      );

  Widget _empty(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [Icon(icon, size: 34, color: AppColors.grey400), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600))]),
      );
}
