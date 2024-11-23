import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ooculo/screens/patients/add_medication_screen.dart';
import 'package:ooculo/screens/patients/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, String>> _reminders = [];

  Future<void> _selectTime(BuildContext context, String medication) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      TextEditingController descriptionController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Reminder Description'),
            content: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _reminders.add({
                      'time': pickedTime.format(context),
                      'description': descriptionController.text,
                      'medication': medication,
                    });
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Reminder added for ${pickedTime.format(context)}'),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToAddMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.teal,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.medication),
            onPressed: _navigateToAddMedication,
            tooltip: 'Add Medication',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
            tooltip: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DeviceStatusCard(),
            const SizedBox(height: 20),
            CalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: (selectedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                _selectTime(context, 'Medication Name');
              },
            ),
            const SizedBox(height: 20),
            RemindersList(
              reminders: _reminders,
              onDelete: (index) {
                setState(() {
                  _reminders.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Device Status Card, CalendarWidget, RemindersList, and TextStyles remain unchanged

// Device Status Card
class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oculoo Device Status',
          style: TextStyles.headerText,
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
                        style: TextStyles.cardText),
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
                    Text('Connected', style: TextStyles.subText),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Calendar Widget
class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const CalendarWidget(
      {required this.selectedDate, required this.onDateSelected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule a Reminder:',
          style: TextStyles.headerText,
        ),
        const SizedBox(height: 10),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.week,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                onDateSelected(selectedDay);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Reminders List Widget
class RemindersList extends StatelessWidget {
  final List<Map<String, String>> reminders;
  final void Function(int) onDelete;

  const RemindersList(
      {required this.reminders, required this.onDelete, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduled Reminders',
          style: TextStyles.headerText,
        ),
        const SizedBox(height: 10),
        reminders.isEmpty
            ? const Text(
                'No reminders added. Tap on a date to add a reminder.',
                style: TextStyles.subText,
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.alarm, color: Colors.teal),
                      title: Text(reminders[index]['time']!),
                      subtitle: Text(
                        reminders[index]['description'] ?? '',
                        style: TextStyles.subText,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(index),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}

// Styles Class for Consistent Text Styles
class TextStyles {
  static const headerText =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const cardText = TextStyle(fontSize: 20);
  static const subText = TextStyle(color: Colors.grey);
}
