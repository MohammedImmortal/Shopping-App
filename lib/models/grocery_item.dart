import 'package:shop_app/models/category.dart';

class GroceryItemModel {
  final String id;
  final String name;
  final int quantity;
  final CategoryModel category;

  GroceryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });
}
