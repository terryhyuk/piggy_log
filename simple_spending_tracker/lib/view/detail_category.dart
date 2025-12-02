import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/view/widget/add_transaction_dialog.dart';
import 'package:simple_spending_tracker/view/widget/buildHeader.dart';
import '../model/category.dart';

class DetailCategory extends StatefulWidget {
  const DetailCategory({super.key});

  @override
  State<DetailCategory> createState() => _DetailCategoryState();
}

class _DetailCategoryState extends State<DetailCategory> {

  // Property
  late final Category category;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;

    if (arg is Category) {
      category = arg;
    }else{
      //fall back Category
      category = Category(
        iconCodePoint: Icons.category.codePoint, 
        iconFontFamily: Icons.category.fontFamily, 
        iconFontPackage: Icons.category.fontPackage, 
        color: "FFFFFFFF", 
        c_name: "Unknow"
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BuildHeader(
              category: category,
              onAddTap: () {
                _openAddTransactionDialog();
              },
              ),
          ],
        ),
      ),
    );
  }

  // Function

  _openAddTransactionDialog() {
    showDialog(
      context: context, 
      builder: (context) => AddTransactionDialog(c_id: category.id!),
      );
  }
}// END
