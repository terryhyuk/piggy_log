import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';

class TransactionList extends StatelessWidget {

  final int categoryId;
  final TransactionHandler transactionHandler = TransactionHandler();
  

  TransactionList({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: transactionHandler.getTransactionsByCategory( categoryId), 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if(!snapshot.hasData || snapshot.data!.isEmpty) {
          return  Text(
            AppLocalizations.of(context)!.noTransactionsFound,
            );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final trx = snapshot.data![index];
            return ListTile(
              title: Text(trx.t_name),
              subtitle: Text(
                DateFormat.yMMMd().format(DateTime.parse(snapshot.data![index].date))),
              trailing: Text(
                trx.amount.toString(),
              style: TextStyle(
                color: snapshot.data![index].type == 'expense' ? Colors.green : Colors.red
              ),
              ),
            );
          },
          );
      },
      );
  }
}// END