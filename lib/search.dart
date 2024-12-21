import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placementtask/sorting.dart';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchUser() async {
    String searchTerm = _searchController.text.trim();

    if (searchTerm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter a name or phone number to search')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      // Check if the input is numeric (for phone number search)
      if (RegExp(r'^\d+$').hasMatch(searchTerm)) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('phone', isEqualTo: int.parse(searchTerm))
            .get();
      } else {
        // Search by name
        querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('name', isEqualTo: searchTerm)
            .get();
      }

      setState(() {
        _searchResults = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Name or Phone Number',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Text('No results found')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return Card(
                              child: ListTile(
                                title: Text(user['name']),
                                subtitle: Text('Phone: ${user['phone']}'),
                                trailing: Text('Age: ${user['age']}'),
                              ),
                            );
                          },
                        ),
                      ),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SortByAgePage(),
                  ));
                },
                icon: Icon(Icons.search))
          ],
        ),
      ),
    );
  }
}
