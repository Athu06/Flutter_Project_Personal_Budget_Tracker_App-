import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_app/screens/dashboard_screen.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const Auth());
}

class Auth extends StatelessWidget {
  const Auth({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          body: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Personal Budget Tracker',
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // You can choose any color you prefer
                    ),
                  ),
                  const SizedBox(height: 30),
                  const TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Login'),
                      Tab(text: 'Signup'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      children: [
                        LoginCard(),
                        SignupCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class LoginCard extends StatefulWidget {
  const LoginCard({Key? key}) : super(key: key);

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Toggle visibility of the password
  bool _isLoading = false; // To track loading state

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      // Attempt login with Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to the Dashboard screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // If user not found, prompt them to sign up
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No user found with this email. Please sign up!'),
        ));
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,   
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signIn();
                          }
                        },
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        DefaultTabController.of(context)?.animateTo(1);
                      },
                      child: const Text(
                        'Create account',
                        // style: TextStyle(color: Colors.black),r
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupCard extends StatefulWidget {
  const SignupCard({Key? key}) : super(key: key);

  @override
  _SignupCardState createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Toggle visibility of the password
  bool _isLoading = false; // To track loading state

// Inside the SignupCard class

Future<void> _signUp() async {
  setState(() {
    _isLoading = true; // Start loading
  });
  try {
    // Create the user in Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Get the user ID
    String uid = userCredential.user!.uid;

    // Save user data to Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'full_name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'uid': uid,
    });

    // Firestore reference for the user's expenses document
    DocumentReference documentReference = FirebaseFirestore.instance.collection("expenses").doc(uid);
    
    try {
      // Fetch the document snapshot
      DocumentSnapshot docSnapshot = await documentReference.get();
      if (docSnapshot.exists) {
        print(docSnapshot.data());  // Logs the document's data
      } else {
        print("No such document!");
      }
    } catch (error) {
      print("Error fetching document: $error");
    }

    // Show the updated SnackBar message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signup successful! Now you can login.')),
    );
  } on FirebaseAuthException catch (e) {
    // Handle Firebase authentication errors
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
  } finally {
    setState(() {
      _isLoading = false; // Stop loading
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signUp();
                          }
                        },
                        child: const Text('Signup'),  
                      ),
                      const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  DefaultTabController.of(context)?.animateTo(0);
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
