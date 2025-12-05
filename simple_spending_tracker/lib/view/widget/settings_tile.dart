import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key, 
    required this.icon, 
    required this.title, 
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        '$title',
        style: const TextStyle(color: Colors.black),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}