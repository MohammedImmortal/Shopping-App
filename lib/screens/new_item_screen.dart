import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shop_app/models/grocery_item.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/data/categories.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});
  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 0;
  CategoryModel _selectedCategory = categories[Categories.fruit]!;
  bool _isLoading = false;

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final Uri url = Uri.https(
          'flutter-test-ecaa6-default-rtdb.firebaseio.com',
          'shopping-list.json');
      http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }),
      )
          .then((res) {
        final Map<String, dynamic> resData = json.decode(res.body);

        if (res.statusCode == 200) {
          Navigator.of(context).pop(
            GroceryItemModel(
              id: resData['name'],
              name: _enteredName,
              quantity: _enteredQuantity,
              category: _selectedCategory,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (String? value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Error! Must be between 1 and 50 Characters.';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Error! Must Enter Positive Number Quantity.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 5),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (CategoryModel? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Rest'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    child: _isLoading
                        ? const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
