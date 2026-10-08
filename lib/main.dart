import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RestaurantWaitlistApp());
}

class RestaurantWaitlistApp extends StatelessWidget {
  const RestaurantWaitlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Waitlist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WaitlistScreen(),
    );
  }
}

// Data model for a Party
class Party {
  final int ticketNumber;
  final String name;
  final int size;

  Party({
    required this.ticketNumber,
    required this.name,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'ticketNumber': ticketNumber,
    'name': name,
    'size': size,
  };

  factory Party.fromJson(Map<String, dynamic> json) => Party(
    ticketNumber: json['ticketNumber'] as int,
    name: json['name'] as String,
    size: json['size'] as int,
  );
}

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key});

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  final List<Party> _waitlist = [];
  int _nextTicketNumber = 1;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load persistent state from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList('waitlist');
    final int? savedCounter = prefs.getInt('nextTicketNumber');

    setState(() {
      if (savedList != null) {
        _waitlist.clear();
        for (String jsonStr in savedList) {
          _waitlist.add(Party.fromJson(jsonDecode(jsonStr)));
        }
      }
      _nextTicketNumber = savedCounter ?? 1;
      _isLoading = false;
    });
  }

  // Save current state to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedList =
    _waitlist.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('waitlist', encodedList);
    await prefs.setInt('nextTicketNumber', _nextTicketNumber);
  }

  // Add a new party to the waitlist
  void _addParty() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final int size = int.parse(_sizeController.text.trim());

      final newParty = Party(
        ticketNumber: _nextTicketNumber,
        name: name,
        size: size,
      );

      setState(() {
        _waitlist.add(newParty);
        _nextTicketNumber++;
      });

      _saveData();

      // Clear input fields
      _nameController.clear();
      _sizeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${newParty.name} (Ticket #${newParty.ticketNumber})'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Remove a party from the waitlist
  void _removeParty(int index) {
    final removed = _waitlist[index];
    setState(() {
      _waitlist.removeAt(index);
    });
    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${removed.name} (Ticket #${removed.ticketNumber})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Waitlist'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Input Form Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Party Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Party Size',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Party size cannot be empty';
                      }
                      final size = int.tryParse(value.trim());
                      if (size == null || size <= 0) {
                        return 'Must be a whole number greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addParty,
                      child: const Text('Add to Waitlist'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Waitlist List View Section
          Expanded(
            child: _waitlist.isEmpty
                ? const Center(
              child: Text(
                'No parties currently waiting.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _waitlist.length,
              itemBuilder: (context, index) {
                final party = _waitlist[index];
                final partiesAhead = index; // Rule 3: count of waiting parties before this one

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('#${party.ticketNumber}'),
                    ),
                    title: Text(
                      party.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Size: ${party.size} | Parties ahead: $partiesAhead',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      tooltip: 'Seat / Remove Party',
                      onPressed: () => _removeParty(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}