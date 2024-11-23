import 'package:flutter/material.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({Key? key}) : super(key: key);

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  void _saveMedication() {
    final String medicationName = _medicationNameController.text;
    final String dosage = _dosageController.text;

    if (medicationName.isNotEmpty && dosage.isNotEmpty) {
      // Add logic to save the medication (e.g., updating state or calling APIs)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$medicationName added successfully!')),
      );

      Navigator.of(context).pop(); // Navigate back after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _medicationNameController,
              decoration: const InputDecoration(labelText: 'Medication Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMedication,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
