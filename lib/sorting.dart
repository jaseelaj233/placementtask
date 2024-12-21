import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SortByAgePage extends StatefulWidget {
  @override
  _SortByAgePageState createState() => _SortByAgePageState();
}

class _SortByAgePageState extends State<SortByAgePage> {
  List<Map<String, dynamic>> _olderUsers = [];
  List<Map<String, dynamic>> _youngerUsers = [];
  bool _isLoading = false;

  void _fetchAndSortUsers() async {
    setState(() {
      _isLoading = true;
      _olderUsers.clear();
      _youngerUsers.clear();
    });

    try {
      // Fetch all users from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      // Categorize users based on age
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> user = doc.data();
        user['id'] = doc.id;

        if (int.parse(user['age']) > 60) {
          _olderUsers.add(user);
        } else {
          _youngerUsers.add(user);
        }
      }

      // Sort each category
      _olderUsers
          .sort((a, b) => int.parse(b['age']).compareTo(int.parse(a['age'])));
      _youngerUsers
          .sort((a, b) => int.parse(b['age']).compareTo(int.parse(a['age'])));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSortUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sort By Age'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Older (Above 60)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _olderUsers.length,
                      itemBuilder: (context, index) {
                        final user = _olderUsers[index];
                        return Card(
                          child: ListTile(
                            title: Text(user['name']),
                            subtitle: Text('Age: ${user['age']}'),
                            trailing: Text('Phone: ${user['phone']}'),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Younger (60 and Below)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _youngerUsers.length,
                      itemBuilder: (context, index) {
                        final user = _youngerUsers[index];
                        return Card(
                          child: ListTile(
                            title: Text(user['name']),
                            subtitle: Text('Age: ${user['age']}'),
                            trailing: Text('Phone: ${user['phone']}'),
                          ),
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
