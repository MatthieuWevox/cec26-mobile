import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../companies/companies_screen.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: CecGlassAppBar(title: Text('Annuaire')),
    body: CompaniesScreen(initiallyMembers: true),
  );
}
