import 'package:shop_app/data/categories.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/grocery_item.dart';

final List<GroceryItemModel> groceryItems = [
  GroceryItemModel(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItemModel(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItemModel(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];
