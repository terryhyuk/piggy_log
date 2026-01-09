import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('th'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @wasRemoved.
  ///
  /// In en, this message translates to:
  /// **'was removed'**
  String get wasRemoved;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'delete?'**
  String get deleteConfirm;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category Created'**
  String get categoryCreated;

  /// No description provided for @newCategoryAdded.
  ///
  /// In en, this message translates to:
  /// **'New category added'**
  String get newCategoryAdded;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category Updated'**
  String get categoryUpdated;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @toTalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get toTalExpense;

  /// No description provided for @setYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Your Budget'**
  String get setYourBudget;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get noTransactions;

  /// No description provided for @recentTranscations.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTranscations;

  /// No description provided for @setMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Budget'**
  String get setMonthlyBudget;

  /// No description provided for @enterYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Budget'**
  String get enterYourBudget;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirm;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter valid amount'**
  String get enterValidAmount;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get pleaseEnterTitle;

  /// No description provided for @recurringTransaction.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transaction'**
  String get recurringTransaction;

  /// No description provided for @searchIcons.
  ///
  /// In en, this message translates to:
  /// **'Search Icons'**
  String get searchIcons;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Transaction'**
  String get confirmDeleteTransaction;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction Updated'**
  String get transactionUpdated;

  /// No description provided for @transactionCreated.
  ///
  /// In en, this message translates to:
  /// **'Transaction Created'**
  String get transactionCreated;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @enterMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter Monthly Budget'**
  String get enterMonthlyBudget;

  /// No description provided for @dateformat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateformat;

  /// No description provided for @errorTransactionDetail.
  ///
  /// In en, this message translates to:
  /// **'Failed to open transaction detail.'**
  String get errorTransactionDetail;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @monthlyBudgetHistory.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget History'**
  String get monthlyBudgetHistory;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @exportDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your data to your device or cloud.'**
  String get exportDesc;

  /// No description provided for @importDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore data from a backup file.'**
  String get importDesc;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Importing will delete all current data and replace it with the file\'s data. Do you want to proceed?'**
  String get restoreWarning;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export Success'**
  String get exportSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore Success'**
  String get restoreSuccess;

  /// No description provided for @categoryNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Category Name Already Exists'**
  String get categoryNameAlreadyExists;

  /// No description provided for @checkTitleAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Please check the description and amount.'**
  String get checkTitleAndAmount;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get description;

  /// No description provided for @viewAnalysis.
  ///
  /// In en, this message translates to:
  /// **'View Analysis'**
  String get viewAnalysis;

  /// No description provided for @spendingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Spending Analysis'**
  String get spendingAnalysis;

  /// No description provided for @categoryBalance.
  ///
  /// In en, this message translates to:
  /// **'Category Balance'**
  String get categoryBalance;

  /// No description provided for @weeklySpendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Spending Trend'**
  String get weeklySpendingTrend;

  /// No description provided for @analysisStep1.
  ///
  /// In en, this message translates to:
  /// **'Analysis Complete! 5+ records found! 🐷'**
  String get analysisStep1;

  /// No description provided for @analysisStep2.
  ///
  /// In en, this message translates to:
  /// **'Check the Radar Chart above for your balance,'**
  String get analysisStep2;

  /// No description provided for @analysisStep3.
  ///
  /// In en, this message translates to:
  /// **'and the Bar Chart below for your weekly peak spending!'**
  String get analysisStep3;

  /// No description provided for @weeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly Spending Trend'**
  String get weeklyTrend;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidAmount;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get categoryNameRequired;

  /// Message shown when the monthly budget is successfully saved
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get budgetUpdated;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @monthlyBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} Budget'**
  String monthlyBudgetTitle(Object month);

  /// No description provided for @totalExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} Total Expense'**
  String totalExpenseTitle(Object month);

  /// No description provided for @historyMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String historyMonthTitle(Object month, Object year);

  /// No description provided for @onboarding_cat_msg.
  ///
  /// In en, this message translates to:
  /// **'Create categories and tap to log!\nLong press to edit or delete them! 🐷'**
  String get onboarding_cat_msg;

  /// No description provided for @onboarding_chart_msg.
  ///
  /// In en, this message translates to:
  /// **'Check your spending ratio\nat a glance with the pie chart! 📊'**
  String get onboarding_chart_msg;

  /// No description provided for @onboarding_setting_msg.
  ///
  /// In en, this message translates to:
  /// **'Safely backup and restore\nyour data right here! 💾'**
  String get onboarding_setting_msg;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Knock knock...? is Piggy Log useful?'**
  String get ratingTitle;

  /// No description provided for @ratingSubTitle.
  ///
  /// In en, this message translates to:
  /// **'If you like it, could you give me 5 stars? (Fingers crossed!)'**
  String get ratingSubTitle;

  /// No description provided for @ratingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sure! I\'d love to!'**
  String get ratingConfirm;

  /// No description provided for @ratingCancel.
  ///
  /// In en, this message translates to:
  /// **'Maybe later...'**
  String get ratingCancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
