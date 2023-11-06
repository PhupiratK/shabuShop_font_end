import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'food.dart'; // Import the food-related code
// import 'dessert.dart';

void main() {
  runApp(MyApp());
}

class TableItem {
  final int id;
  final String name;

  TableItem({required this.id, required this.name});

  factory TableItem.fromJson(Map<String, dynamic> json) {
    return TableItem(id: json['id'], name: json['name']);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TableList(),
    );
  }
}

class TableList extends StatefulWidget {
  @override
  _TableListState createState() => _TableListState();
}

class _TableListState extends State<TableList> {
  Future<List<TableItem>> fetchTables() async {
    final response = await http.get(Uri.parse('http://localhost:3001/table'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => TableItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tables');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShabuShop Tables'),
        actions: <Widget>[],
      ),
      body: FutureBuilder<List<TableItem>>(
        future: fetchTables(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final tableItems = snapshot.data!;
            if (tableItems.isNotEmpty) {
              return Center(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: tableItems.length,
                  itemBuilder: (context, index) {
                    return TableItemCard(tableItems[index]);
                  },
                ),
              );
            } else {
              return Center(child: Text('No tables available.'));
            }
          } else {
            return Center(child: Text('No tables available.'));
          }
        },
      ),
    );
  }
}

class TableItemCard extends StatelessWidget {
  final TableItem tableItem;

  TableItemCard(this.tableItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodList()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.local_dining, size: 40, color: Colors.orange),
            ListTile(
              title: Text('Table: ${tableItem.name}'),
            ),
          ],
        ),
      ),
    );
  }
}
