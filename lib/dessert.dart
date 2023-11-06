import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class DessertItem {
  final int id;
  final String name;
  final double price;
  final String url_img;

  DessertItem({
    required this.id,
    required this.name,
    required this.price,
    required this.url_img,
  });

  factory DessertItem.fromJson(Map<String, dynamic> json) {
    return DessertItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      url_img: json['url_img'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('ShabuShop Food Menu'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
                Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
                Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DessertList(),
              Container(
                child: Center(
                  child: Text('Second Tab Content'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('Third Tab Content'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DessertList extends StatefulWidget {
  @override
  _DessertListState createState() => _DessertListState();
}

class _DessertListState extends State<DessertList> {
  Future<List<DessertItem>> fetchDessert() async {
    final response = await http.get(Uri.parse('http://localhost:3001/dessert'));

    if (response.statusCode == 200) {
      // Successfully fetched data
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => DessertItem.fromJson(item)).toList();
    } else {
      // Handle HTTP error
      print('HTTP error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load dessert items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DessertItem>>(
      future: fetchDessert(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final dessertItems = snapshot.data!;
          if (dessertItems.isNotEmpty) {
            return ListView.builder(
              itemCount: dessertItems.length,
              itemBuilder: (context, index) {
                return DessertItemCard(dessertItems[index]);
              },
            );
          } else {
            return Center(child: Text('No food items available.'));
          }
        } else {
          return Center(child: Text('No food items available.'));
        }
      },
    );
  }
}

class DessertItemCard extends StatelessWidget {
  final DessertItem dessertItem;

  DessertItemCard(this.dessertItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(dessertItem.url_img, width: 80, height: 80),
        title: Text(dessertItem.name),
        subtitle: Text('Price: ${dessertItem.price} THB'),
      ),
    );
  }
}
