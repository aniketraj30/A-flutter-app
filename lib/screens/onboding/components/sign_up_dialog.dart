import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:ooculo/screens/entryPoint/entry_point.dart';
import 'package:flutter/services.dart'; // Import for root bundle access
import 'package:encrypt/encrypt.dart' as encrypt;

class SignUpDialog extends StatefulWidget {
  @override
  _SignUpDialogState createState() => _SignUpDialogState();
}

class _SignUpDialogState extends State<SignUpDialog> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String _userRole = 'Patient';
  String? _age;
  bool isShowLoading = false;
  bool isShowConfetti = false;

  late SMITrigger success;
  late SMITrigger error;
  late SMITrigger reset;
  late SMITrigger confetti;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _encryptionKey;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    success = controller.findInput<bool>('Check') as SMITrigger;
    error = controller.findInput<bool>('Error') as SMITrigger;
    reset = controller.findInput<bool>('Reset') as SMITrigger;
    confetti = controller.findInput<bool>('Trigger explosion') as SMITrigger;
  }

  void _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    setState(() {
      _age = age.toString();
    });
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      _calculateAge(picked);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEncryptionKey();
  }

  Future<void> _loadEncryptionKey() async {
    try {
      final key = await rootBundle.loadString('assets/encryption_key.txt');
      setState(() {
        _encryptionKey = key.trim(); // Store the key after trimming whitespace
      });
      print("Loaded encryption key: $_encryptionKey");
      print("Key length: ${_encryptionKey?.length}"); // Check the length
    } catch (e) {
      print("Error loading encryption key: $e");
    }
  }

  String encryptPassword(String password) {
    if (_encryptionKey == null) {
      throw Exception("Encryption key not loaded");
    }
    final key = encrypt.Key.fromUtf8(_encryptionKey!); // Use the loaded key
    final iv = encrypt.IV.fromLength(16); // IV length is correct

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);

    return encrypted.base64;
  }

  Future<void> _signUp() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Reset error messages
    _firstNameError = null;
    _lastNameError = null;
    _passwordError = null;

    // Check for empty fields
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      if (firstName.isEmpty) {
        _firstNameError = "First name cannot be empty";
      }
      if (lastName.isEmpty) {
        _lastNameError = "Last name cannot be empty";
      }
      if (password.isEmpty) {
        _passwordError = "Password cannot be empty";
      }
      setState(() {});
      return;
    }

    // Validation for numeric values in first and last name
    if (RegExp(r'\d').hasMatch(firstName)) {
      _firstNameError = "First name cannot contain numeric values";
    }
    if (RegExp(r'\d').hasMatch(lastName)) {
      _lastNameError = "Last name cannot contain numeric values";
    }
    if (password != confirmPassword) {
      _passwordError = "Passwords do not match";
    }

    // If there are any errors, show them and return
    if (_firstNameError != null || _lastNameError != null || _passwordError != null) {
      setState(() {}); // Trigger a rebuild to show error messages
      return;
    }

    // Proceed with sign-up logic if no errors
    try {
      String hashedPassword = encryptPassword(password);

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection("Users").doc(userCredential.user?.email).set({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": hashedPassword,
      });

      // Handle successful sign-up (e.g., navigate to another screen)
    } catch (e) {
      // Handle sign-up error
      print("Error signing up: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            height: 670,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 30),
                  blurRadius: 60,
                ),
                const BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 30),
                  blurRadius: 60,
                ),
              ],
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 34,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "As",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ToggleButtons(
                          isSelected: [_userRole == 'Patient', _userRole == 'Guardian'],
                          onPressed: (index) {
                            setState(() {
                              _userRole = index == 0 ? 'Patient' : 'Guardian';
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Patient", style: TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Guardian", style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(labelText: "First Name"),
                          ),
                        ),
                        if (_firstNameError != null) // Show error message
                          Text(_firstNameError!, style: TextStyle(color: Colors.red)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(labelText: "Last Name"),
                          ),
                        ),
                        if (_lastNameError != null) // Show error message
                          Text(_lastNameError!, style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: "Date of Birth",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () => _selectDOB(context),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    if (_passwordError != null) // Show error message
                      Text(_passwordError!, style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: "Confirm Password"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF77D8E),
                        minimumSize: const Size(double.infinity, 56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          ),
                        ),
                      ),
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text(
                        "Already a member? Sign In",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isShowLoading)
          CustomPositioned(
            child: RiveAnimation.asset(
              'assets/RiveAssets/check.riv',
              onInit: _onRiveInit,
            ),
          ),
        if (isShowConfetti)
          CustomPositioned(
            scale: 6,
            child: RiveAnimation.asset(
              "assets/RiveAssets/confetti.riv",
              onInit: _onRiveInit,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({super.key, this.scale = 1, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 100,
            width: 100,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
