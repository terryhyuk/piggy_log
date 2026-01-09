// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get wasRemoved => 'was removed';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleted => 'Deleted';

  @override
  String get deleteConfirm => 'delete?';

  @override
  String get categoryName => 'Category Name';

  @override
  String get color => 'Color';

  @override
  String get categoryCreated => 'Category Created';

  @override
  String get newCategoryAdded => 'New category added';

  @override
  String get categoryUpdated => 'Category Updated';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get toTalExpense => 'Total Expense';

  @override
  String get setYourBudget => 'Set Your Budget';

  @override
  String get noTransactions => 'No Transactions';

  @override
  String get recentTranscations => 'Recent Transactions';

  @override
  String get setMonthlyBudget => 'Set Monthly Budget';

  @override
  String get enterYourBudget => 'Enter Your Budget';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get add => 'Add';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get memo => 'Memo';

  @override
  String get recurring => 'Recurring';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get selectDate => 'Select Date';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get currency => 'Currency';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get enterValidAmount => 'Enter valid amount';

  @override
  String get pleaseEnterTitle => 'Please enter title';

  @override
  String get recurringTransaction => 'Recurring Transaction';

  @override
  String get searchIcons => 'Search Icons';

  @override
  String get confirmDeleteTransaction => 'Confirm Delete Transaction';

  @override
  String get transactionUpdated => 'Transaction Updated';

  @override
  String get transactionCreated => 'Transaction Created';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get transaction => 'Transaction';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get enterMonthlyBudget => 'Enter Monthly Budget';

  @override
  String get dateformat => 'Date Format';

  @override
  String get errorTransactionDetail => 'Failed to open transaction detail.';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name';

  @override
  String get monthlyBudgetHistory => 'Monthly Budget History';

  @override
  String get remaining => 'Remaining';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get budget => 'Budget';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get exportDesc => 'Save your data to your device or cloud.';

  @override
  String get importDesc => 'Restore data from a backup file.';

  @override
  String get warning => 'Warning';

  @override
  String get restoreWarning =>
      'Importing will delete all current data and replace it with the file\'s data. Do you want to proceed?';

  @override
  String get confirm => 'Confirm';

  @override
  String get exportSuccess => 'Export Success';

  @override
  String get restoreSuccess => 'Restore Success';

  @override
  String get categoryNameAlreadyExists => 'Category Name Already Exists';

  @override
  String get checkTitleAndAmount => 'Please check the description and amount.';

  @override
  String get description => 'description';

  @override
  String get viewAnalysis => 'View Analysis';

  @override
  String get spendingAnalysis => 'Spending Analysis';

  @override
  String get categoryBalance => 'Category Balance';

  @override
  String get weeklySpendingTrend => 'Weekly Spending Trend';

  @override
  String get analysisStep1 => 'Analysis Complete! 5+ records found! 🐷';

  @override
  String get analysisStep2 => 'Check the Radar Chart above for your balance,';

  @override
  String get analysisStep3 =>
      'and the Bar Chart below for your weekly peak spending!';

  @override
  String get weeklyTrend => 'Weekly Spending Trend';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get invalidAmount => 'Please enter a valid number';

  @override
  String get categoryNameRequired => 'Category name is required';

  @override
  String get budgetUpdated => 'Budget updated successfully';

  @override
  String get done => 'Done';

  @override
  String monthlyBudgetTitle(Object month) {
    return '$month Budget';
  }

  @override
  String totalExpenseTitle(Object month) {
    return '$month Total Expense';
  }

  @override
  String historyMonthTitle(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get onboarding_cat_msg =>
      'Create categories and tap to log!\nLong press to edit or delete them! 🐷';

  @override
  String get onboarding_chart_msg =>
      'Check your spending ratio\nat a glance with the pie chart! 📊';

  @override
  String get onboarding_setting_msg =>
      'Safely backup and restore\nyour data right here! 💾';

  @override
  String get review => 'If you like this app, please leave a rating!';
}
