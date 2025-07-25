import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _userData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _editing = {};

  bool _isLoading = true;

  final List<String> _fields = [
    'name',
    'email',
    'phone',
    'address',
    'city',
    'postalCode',
    'gender',
    'dateOfBirth',
    'country',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() ?? {};

    for (var field in _fields) {
      _controllers[field] = TextEditingController(text: data[field] ?? '');
      _editing[field] = false;
    }

    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updatedData = {
      for (var field in _fields) field: _controllers[field]!.text.trim()
    };

    await _firestore.collection('users').doc(uid).update(updatedData);

    setState(() {
      for (var field in _fields) {
        _editing[field] = false;
        _userData[field] = _controllers[field]!.text.trim();
      }
    });

    Fluttertoast.showToast(
      msg: "Login Successful",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Widget _buildField(String label, String key) {
    if (_editing[key] == true) {
      if (key == 'gender') {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<String>(
            value: _controllers[key]!.text.isEmpty ? null : _controllers[key]!.text,
            items: ['male', 'Female', 'prefer not say']
                .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
                .toList(),
            onChanged: (value) {
              _controllers[key]!.text = value ?? '';
            },
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      } else if (key == 'country') {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _controllers[key],
            readOnly: true,
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (Country country) {
                  setState(() {
                    _controllers[key]!.text = '${country.flagEmoji} ${country.name}';
                  });
                },
              );
            },
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      } else if (key == 'dateOfBirth') {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            controller: _controllers[key],
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(_controllers[key]!.text) ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _controllers[key]!.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextField(
            controller: _controllers[key],
            keyboardType: key == 'phone' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        );
      }
    } else {
      return InkWell(
        onTap: () {
          setState(() {
            _editing[key] = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                _controllers[key]!.text.isEmpty ? 'Not provided' : _controllers[key]!.text,
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A38),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFF8E7)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color(0xFFFF9800), size: 24),
            SizedBox(width: 8),
            Text(
              'PROFILE',
              style: TextStyle(
                color: Color(0xFFFFF8E7),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF1E2A38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 65,
                color: Color(0xFFFFF8E7),
              ),
            ),
            const SizedBox(height: 20),
            ..._fields.map((field) => _buildField(
              field == 'postalCode'
                  ? 'Postal Code'
                  : field == 'dateOfBirth'
                  ? 'Date of Birth'
                  : field[0].toUpperCase() + field.substring(1),
              field,
            )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
