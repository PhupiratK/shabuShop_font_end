import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class DrinkItem {
  final int id;
  final String name;
  final double price;
  final String img_url;

  DrinkItem({
    required this.id,
    required this.name,
    required this.price,
    required this.img_url,
  });

  factory DrinkItem.fromJson(Map<String, dynamic> json) {
    return DrinkItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      img_url:
          json['img_url'] ?? 'default_image_url', // Provide a default value
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
              DrinkList(),
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

class DrinkList extends StatefulWidget {
  @override
  _DrinkListState createState() => _DrinkListState();
}

class _DrinkListState extends State<DrinkList> {
  Future<List<DrinkItem>> fetchDrink() async {
    final response = await http.get(Uri.parse('http://localhost:3001/drink'));

    if (response.statusCode == 200) {
      // Successfully fetched data
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => DrinkItem.fromJson(item)).toList();
    } else {
      // Handle HTTP error
      print('HTTP error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load drink items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DrinkItem>>(
      future: fetchDrink(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final drinkItems = snapshot.data!;
          if (drinkItems.isNotEmpty) {
            return ListView.builder(
              itemCount: drinkItems
                  .length, // Fixed the error by adding an itemCount property.
              itemBuilder: (context, index) {
                return DrinkItemCard(drinkItems[index]);
              },
            );
          } else {
            return Center(child: Text('No drink items available.'));
          }
        } else {
          return Center(child: Text('No food items available.'));
        }
      },
    );
  }
}

class DrinkItemCard extends StatelessWidget {
  final DrinkItem drinkItem;

  DrinkItemCard(this.drinkItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(drinkItem.img_url, width: 80, height: 80),
        title: Text(drinkItem.name),
        subtitle: Text('Price: ${drinkItem.price} THB'),
      ),
    );
  }
}
