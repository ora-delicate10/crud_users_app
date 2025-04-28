import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserCrudPage(),
    );
  }
}

class UserCrudPage extends StatefulWidget {
  @override
  _UserCrudPageState createState() => _UserCrudPageState();
}

class _UserCrudPageState extends State<UserCrudPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<dynamic> _users = [];

  // Function to register user
  Future<void> registerUser() async {
    var url = Uri.parse('http://192.168.59.86:3000/users');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_name': _nameController.text,
        'gender': _genderController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User Registered!')));
      _nameController.clear();
      _genderController.clear();
      _passwordController.clear();
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Register')));
    }
  }

  // Function to fetch users
  Future<void> fetchUsers() async {
    var url = Uri.parse('http://192.168.59.86:3000/users');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _users = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch users')));
    }
  }

  // Function to delete user
  Future<void> deleteUser(int userId) async {
    var url = Uri.parse('http://192.168.59.86:3000/users/$userId');
    var response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User Deleted')));
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Delete')));
    }
  }

  // Function to show update dialog
  void updateUserDialog(int userId, String currentName, String currentGender) {
    TextEditingController _updateNameController =
        TextEditingController(text: currentName);
    TextEditingController _updateGenderController =
        TextEditingController(text: currentGender);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _updateNameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
              TextField(
                controller: _updateGenderController,
                decoration: InputDecoration(labelText: 'Gender'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                updateUser(
                    userId, _updateNameController.text, _updateGenderController.text);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Function to update user
  Future<void> updateUser(int userId, String newName, String newGender) async {
    var url = Uri.parse('http://192.168.59.86:3000/users/$userId');
    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_name': newName,
        'gender': newGender,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User Updated')));
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Update')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple CRUD App')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'User Name')),
            TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Gender')),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Register User'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  var user = _users[index];
                  return ListTile(
                    title: Text(user['user_name'] ?? ''),
                    subtitle: Text('Gender: ${user['gender'] ?? ''}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteUser(user['user_id']);
                      },
                    ),
                    onTap: () {
                      updateUserDialog(
                          user['user_id'], user['user_name'], user['gender']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}