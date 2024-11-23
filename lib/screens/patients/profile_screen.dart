import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String name = 'Loading...';
  String age = 'Loading...';
  String location = 'New York, USA';
  String emergencyContact = 'Mary Doe - 1234567890';
  String guardian = 'James Doe - 0987654321';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDetails = await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.email)
          .get();
      final userData = userDetails.data();
      setState(() {
        name = userData?['firstName'] ?? 'Unknown User';
        age = userData?['age']?.toString() ?? 'Unknown Age';
      });
    } catch (e) {
      print('Error fetching user details: $e');
      // Handle error appropriately, e.g., show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildHealthInsights(),
            const SizedBox(height: 20),
            _buildEmergencyContacts(),
            const SizedBox(height: 20),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  // Profile Header with avatar and personal info
  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Allow user to pick a new avatar (you can use a package for image picker)
          },
          child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/avatar.png'),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('Age: $age'),
            Text('Location: $location'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to edit profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      name: name,
                      age: age,
                      location: location,
                      emergencyContact: emergencyContact,
                      guardian: guardian,
                      onSave: (updatedName, updatedAge, updatedLocation,
                          updatedEmergencyContact, updatedGuardian) {
                        setState(() {
                          name = updatedName;
                          age = updatedAge;
                          location = updatedLocation;
                          emergencyContact = updatedEmergencyContact;
                          guardian = updatedGuardian;
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ],
    );
  }

  // Health Insights & Tips
  Widget _buildHealthInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Insights & Tips',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Card(
          child: ListTile(
            title: Text('Tip of the Day: Stay hydrated!'),
            subtitle:
                Text('Drinking enough water is essential for your health.'),
          ),
        ),
        const SizedBox(height: 10),
        const Card(
          child: ListTile(
            title: Text('Recent Health Update:'),
            subtitle:
                Text('Your blood pressure is stable. Keep up the good work!'),
          ),
        ),
      ],
    );
  }

  // Emergency Contacts
  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Contacts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.phone, color: Colors.red),
          title: Text('Guardian: $guardian'),
          subtitle: const Text('Tap to call'),
          // Removed onTap functionality for calling
          // onTap: () {
          //   _makePhoneCall('tel:$guardian');
          // },
        ),
        ListTile(
          leading: const Icon(Icons.phone, color: Colors.red),
          title: Text('Emergency: $emergencyContact'),
          subtitle: const Text('Tap to call'),
          // Removed onTap functionality for calling
          // onTap: () {
          //   _makePhoneCall('tel:$emergencyContact');
          // },
        ),
      ],
    );
  }

  // Settings section for account management
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (bool value) {
                // Toggle notifications
              },
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock, color: Colors.blue),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Privacy Settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out'),
            onTap: () {
              // Log out functionality
            },
          ),
        ),
      ],
    );
  }
}

// Edit Profile screen
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String age;
  final String location;
  final String emergencyContact;
  final String guardian;
  final Function(String, String, String, String, String) onSave;

  EditProfileScreen({
    required this.name,
    required this.age,
    required this.location,
    required this.emergencyContact,
    required this.guardian,
    required this.onSave,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _guardianController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with the current profile information
    _nameController.text = widget.name;
    _ageController.text = widget.age;
    _locationController.text = widget.location;
    _emergencyContactController.text = widget.emergencyContact;
    _guardianController.text = widget.guardian;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit your profile details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _guardianController,
              decoration: const InputDecoration(
                labelText: 'Guardian',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  _nameController.text,
                  _ageController.text,
                  _locationController.text,
                  _emergencyContactController.text,
                  _guardianController.text,
                );
                Navigator.pop(context); // Go back to profile screen
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}
