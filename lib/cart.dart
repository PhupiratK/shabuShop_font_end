import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Replace these imports with your actual 'dessert.dart' and 'drink.dart'
import 'dessert.dart';
import 'drink.dart';

class FoodItem {
  final int id;
  final String name;
  final double price;
  final String img_url;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.img_url,
    this.quantity = 0, // Default quantity to 0
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      img_url: json['img_url'],
    );
  }
}

class Cart {
  List<FoodItem> items = [];

  void addToCart(FoodItem foodItem) {
    // Check if the item is already in the cart
    if (items.contains(foodItem)) {
      final existingItem = items.firstWhere((item) => item.id == foodItem.id);
      existingItem.quantity++;
    } else {
      foodItem.quantity = 1;
      items.add(foodItem);
    }
  }

  void removeFromCart(FoodItem foodItem) {
    items.remove(foodItem);
  }

  void clearCart() {
    items.clear();
  }
}

class FoodList extends StatefulWidget {
  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  int _currentIndex = 0;
  final Cart cart = Cart();

  Future<List<FoodItem>> fetchFood() async {
    final response = await http.get(Uri.parse('http://localhost:3001/food'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => FoodItem.fromJson(item)).toList();
    } else {
      print('HTTP error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load food items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShabuShop Food Menu'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_basket),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage(cart)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: fetchFood(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final foodItems = snapshot.data!;
            if (foodItems.isNotEmpty) {
              return ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  return FoodItemCard(foodItems[index], cart.addToCart);
                },
              );
            } else {
              return Center(child: Text('No food items available.'));
            }
          } else {
            return Center(child: Text('No food items available.'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrinkListPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DessertListPage()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            label: 'อาหาร',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_drink_outlined),
            label: 'เครื่องดื่ม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.icecream_outlined),
            label: 'ของหวาน',
          ),
        ],
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final Function(FoodItem) onAddToCart;

  FoodItemCard(this.foodItem, this.onAddToCart);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(foodItem.img_url, width: 80, height: 80),
        title: Text(foodItem.name),
        subtitle: Text('Price: ${foodItem.price} THB'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                onAddToCart(foodItem);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DessertListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dessert List'),
      ),
      body: DessertList(),
    );
  }
}

class DrinkListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drink List'),
      ),
      body: DrinkList(),
    );
  }
}

class CartPage extends StatefulWidget {
  final Cart cart;

  CartPage(this.cart);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> submitOrder(BuildContext context) async {
    // Remove items with a quantity of 0 from the cart
    widget.cart.items.removeWhere((foodItem) => foodItem.quantity == 0);

    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty. Add items to the cart first.')),
      );
      return;
    }

    final orderData = widget.cart.items.map((foodItem) {
      return {
        'food_id': foodItem.id,
        'amount': foodItem.quantity,
      };
    }).toList();

    final order = {
      'order_items': orderData,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/cart'), // Replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(order),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to place the order');
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place the order: ${e.toString()}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed successfully')),
    );

    setState(() {
      widget.cart.clearCart();
    });
  }

  // Future<void> submitOrder(BuildContext context) async {
  //   // Remove items with a quantity of 0 from the cart
  //   widget.cart.items.removeWhere((foodItem) => foodItem.quantity == 0);

  //   if (widget.cart.items.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Cart is empty. Add items to the cart first.')),
  //     );
  //     return;
  //   }

  //   final orderData = widget.cart.items.map((foodItem) {
  //     return {
  //       'food_id': foodItem.id,
  //       'amount': foodItem.quantity,
  //     };
  //   }).toList();

  //   final order = {
  //     'order_items': orderData,
  //   };

  //   final response = await http.post(
  //     Uri.parse('http://localhost:3001/cart'), // Replace with your API URL
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(order),
  //   );

  //   print('Response Status Code: ${response.statusCode}');
  //   print('Response Body: ${response.body}');

  //   if (response.statusCode == 201) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Order placed successfully')),
  //     );

  //     setState(() {
  //       widget.cart.clearCart();
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to place the order')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(widget.cart.items[index].name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${widget.cart.items[index].price} THB'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (widget.cart.items[index].quantity > 0) {
                                  setState(() {
                                    widget.cart.items[index].quantity--;
                                  });
                                }
                              },
                            ),
                            Text(
                                'Quantity: ${widget.cart.items[index].quantity}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  widget.cart.items[index].quantity++;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  widget.cart
                                      .removeFromCart(widget.cart.items[index]);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              submitOrder(context);
            },
            child: Text('Submit Order'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FoodList(),
    );
  }
}
