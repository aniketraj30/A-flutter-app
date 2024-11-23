import 'package:flutter/material.dart';
// import 'package:ooculo/screens/patients/add_medication_screen.dart'; // Ensure this file exists
import 'package:ooculo/screens/patients/add_medication_screen.dart';


class GuardianDashboardScreen extends StatefulWidget {
  final String patientName;

  const GuardianDashboardScreen({Key? key, required this.patientName})
      : super(key: key);

  @override
  _GuardianDashboardScreenState createState() =>
      _GuardianDashboardScreenState();
}

class _GuardianDashboardScreenState extends State<GuardianDashboardScreen> {
  final List<Map<String, dynamic>> _patients = [
    {'name': 'John Doe', 'deviceStatus': '85% - Connected'},
    {'name': 'Jane Smith', 'deviceStatus': '60% - Disconnected'},
    {'name': 'Robert Brown', 'deviceStatus': '95% - Connected'},
  ];

  final Map<String, List<Map<String, String>>> _reminders = {
    'John Doe': [
      {'time': '8:00 AM', 'description': 'Morning Medication'},
      {'time': '8:00 PM', 'description': 'Evening Medication'},
    ],
    'Jane Smith': [
      {'time': '7:00 AM', 'description': 'Blood Pressure Check'},
    ],
    'Robert Brown': [],
  };

  final Map<String, Map<String, String>> _patientVitals = {
    'John Doe': {'Heart Rate': '78 bpm', 'Blood Pressure': '120/80'},
    'Jane Smith': {'Heart Rate': '72 bpm', 'Blood Pressure': '125/85'},
    'Robert Brown': {'Heart Rate': '80 bpm', 'Blood Pressure': '110/75'},
  };

  final Map<String, List<String>> _medicationLog = {
    'John Doe': ['Medication A - 8:00 AM', 'Medication B - 8:00 PM'],
    'Jane Smith': ['Medication C - 7:00 AM'],
    'Robert Brown': ['Medication D - 9:00 AM'],
  };

  String _selectedPatient = '';

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.patientName; // Default patient
  }

  void _addReminder(String patientName) {
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Reminder for $patientName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _reminders.putIfAbsent(patientName, () => []).add({
                        'time': pickedTime.format(context),
                        'description': descriptionController.text,
                      });
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Select Time'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteReminder(String patientName, int index) {
    setState(() {
      _reminders[patientName]?.removeAt(index);
    });
  }

  void _addPatient() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Add New Patient'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter patient name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _patients.add({
                      'name': nameController.text,
                      'deviceStatus': 'Not set',
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // void _goToAddMedicationPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => AddMedicationScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final selectedReminders = _reminders[_selectedPatient] ?? [];
    final selectedPatientData = _patients.firstWhere(
      (patient) => patient['name'] == _selectedPatient,
    );
    final selectedVitals = _patientVitals[_selectedPatient] ?? {};
    final selectedMedicationLog = _medicationLog[_selectedPatient] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Dashboard'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPatient,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Dropdown
            _buildPatientDropdown(),

            // Device Status Section
            _buildDeviceStatusSection(selectedPatientData),

            const SizedBox(height: 20),

            // Medication Log Section
            _buildMedicationLogSection(selectedMedicationLog),

            const SizedBox(height: 20),

            // Tab Bar for Reminders, Vitals, etc.
            DefaultTabController(
              length: 3, // 3 tabs: Reminders, Vitals, Medication Log
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.teal,
                    tabs: const [
                      Tab(text: 'Reminders'),
                      Tab(text: 'Vitals'),
                      Tab(text: 'Medication Log'),
                    ],
                  ),
                  Container(
                    height: 200, // Adjust height to fit your content
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBarView(
                      children: [
                        // Reminders Tab
                        _buildRemindersTab(selectedReminders),
                        // Vitals Tab
                        _buildVitalsTab(selectedVitals),
                        // Medication Log Tab
                        _buildMedicationLogTab(selectedMedicationLog),
                      ],
                    ),
                  ),
                ],
              ),
            ),  
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
          );  
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Patient Dropdown widget
  Widget _buildPatientDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: DropdownButton<String>(
        value: _selectedPatient,
        isExpanded: true,
        underline: SizedBox(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedPatient = newValue;
            });
          }
        },
        items: _patients
            .map((patient) => DropdownMenuItem<String>(
                  value: patient['name'],
                  child: Text(patient['name']),
                ))
            .toList(),
      ),
    );
  }

  // Device Status Section (Updated)
  Widget _buildDeviceStatusSection(Map<String, dynamic> patientData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oculoo Device Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.battery_full,
                        color: Colors.green, size: 30),
                    const SizedBox(width: 10),
                    const Text('Battery Level: 85%',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                const LinearProgressIndicator(value: 0.85),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bluetooth_connected,
                        color: Colors.blue, size: 18),
                    SizedBox(width: 5),
                    Text('Connected', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Medication Log Section
  Widget _buildMedicationLogSection(List<String> medicationLog) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medication Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (var log in medicationLog)
              Text(log, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Reminders Tab
  Widget _buildRemindersTab(List<Map<String, String>> reminders) {
    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(reminders[index]['description']!),
          subtitle: Text(reminders[index]['time']!),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteReminder(_selectedPatient, index),
          ),
        );
      },
    );
  }

  Widget _buildVitalsTab(Map<String, String> vitals) {
    return ListView.builder(
      itemCount: vitals.length,
      itemBuilder: (context, index) {
        String key = vitals.keys.elementAt(index);
        return ListTile(
          title: Text('$key: ${vitals[key]}'),
        );
      },
    );
  }

  // Medication Log Tab
  Widget _buildMedicationLogTab(List<String> medicationLog) {
    return ListView.builder(
      itemCount: medicationLog.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(medicationLog[index]),
        );
      },
    );
  }
}
