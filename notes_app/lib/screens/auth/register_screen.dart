import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/providers/auth.provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBinusian;
  String? _selectedMajor;
  String? _selectedRegionCampus;

  final List<String> _binusianList = [
    'B24', 'B25', 'B26', 'B27', 'B28', 'B29', 'B30'
  ];

  final List<String> _majorList = [
    'Accounting',
    'Business Analytics',
    'Business Creation',
    'Business Management',
    'Computer Engineering',
    'Computer Science',
    'Computer Science - Global Class',
    'Creative Communication',
    'Data Science',
    'Digital Business',
    'Digital Communication',
    'Fashion',
    'Finance',
    'Global Business Marketing',
    'Information Systems',
    'Interior Design',
    'Management',
    'Public Relations',
    'Visual Communication Design',
  ];

  final List<String> _regionCampusList = [
    'Alam Sutera',
    'Bandung',
    'Bekasi',
    'Kemanggisan',
    'Malang',
    'Palembang',
    'Semarang',
    'Senayan',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  if (_usernameController.text.trim().isEmpty ||
      _emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty ||
      _selectedBinusian == null ||
      _selectedMajor == null ||
      _selectedRegionCampus == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  final auth = Provider.of<AuthProvider>(context, listen: false);
  final success = await auth.register(
    username: _usernameController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
    binusian: _selectedBinusian,
    major: _selectedMajor,
    regionCampus: _selectedRegionCampus,
  );
  if (success && mounted) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            isDense: true,
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Image.asset('assets/images/Logo.jpg', height: 80),
              ),
              const SizedBox(height: 32),
              _buildTextField(controller: _usernameController, label: 'User Name'),
              _buildTextField(controller: _emailController, label: 'Email'),
              _buildTextField(controller: _passwordController, label: 'New Password', obscure: true),
              _buildDropdown(
                label: 'Binusian',
                value: _selectedBinusian,
                items: _binusianList,
                onChanged: (val) => setState(() => _selectedBinusian = val),
              ),
              _buildDropdown(
                label: 'Major',
                value: _selectedMajor,
                items: _majorList,
                onChanged: (val) => setState(() => _selectedMajor = val),
              ),
              _buildDropdown(
                label: 'Region Campus',
                value: _selectedRegionCampus,
                items: _regionCampusList,
                onChanged: (val) => setState(() => _selectedRegionCampus = val),
              ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 1),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Already have account? Sign In Here'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}