import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/category_handler.dart';
import 'package:simple_spending_tracker/view/widget/button_widget.dart';
import 'package:simple_spending_tracker/view/widget/category_sheet.dart';

import '../model/category.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  // Property
  final CategoryHandler categoryHandler = CategoryHandler();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Transaction')),

    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 1, // ← 카테고리 없음 → + 하나만
      itemBuilder: (context, index) {
        if (index == 0) {
          return ButtonWidget(onTap: openCategorySheet);
        }
      },
    ),
  );
}


  // --- Functions ---

loadCategories() async {
  final list = await categoryHandler.queryCategory(); // ← 진짜 DB 조회
  categories = list;
  setState(() {});
}

openCategorySheet({Category? category}){
  showModalBottomSheet(
    context: context, 
    builder: (context) => CategorySheet(),
    );
}

}// END