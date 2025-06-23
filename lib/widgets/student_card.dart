import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String id;
  final void Function()? onTap;

  const StudentCard({super.key, required this.name, required this.id, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade300,
          child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('ID: $id'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}
