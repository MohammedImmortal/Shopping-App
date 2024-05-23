import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shop_app/data/categories.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/grocery_item.dart';
import 'package:shop_app/screens/new_item_screen.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  List<GroceryItemModel> _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  void _loadData() async {
    final Uri url = Uri.https(
      'flutter-test-ecaa6-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    try {
      final http.Response res = await http.get(url);
      if (res.statusCode >= 400) {
        setState(() {
          _error = 'Failed to Fetch Data, Please Try Again Later';
        });
        return;
      }

      if (res.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> loadedData = json.decode(res.body);
      final List<GroceryItemModel> loadedItems = [];
      for (var item in loadedData.entries) {
        final CategoryModel category = categories.entries
            .firstWhere(
              (element) => element.value.title == item.value['category'],
            )
            .value;
        loadedItems.add(
          GroceryItemModel(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
        setState(
          () {
            _groceryItems = loadedItems;
            _isLoading = false;
          },
        );
      }
    } catch (err) {
      setState(() {
        _error = 'Something went Wrong, Please Try Again Later';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Item added yet!'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (_) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            leading: Container(
              height: 25,
              width: 25,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
            title: Text(_groceryItems[index].name),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Crocery'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }

  void _removeItem(GroceryItemModel item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final Uri url = Uri.https(
      'flutter-test-ecaa6-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't Delete The Item!"),
        ),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItemModel>(
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }
}
