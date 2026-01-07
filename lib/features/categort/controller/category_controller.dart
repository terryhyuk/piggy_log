import 'package:get_x/get.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent:
//    Acts as a lightweight signaling bus for category-related data changes.
//    Provides a reactive trigger that other controllers or UI components can 
//    listen to for synchronizing their state when categories are modified.
// -----------------------------------------------------------------------------

class CategoryController extends GetxController {
  
  // 1. Reactive Signal Trigger:
  // An observable integer that increments whenever a change occurs.
  // This serves as a lightweight alternative to passing full object streams.
  RxInt refreshTrigger = 0.obs;

  /// Broadcasts a notification to all listeners that category data has changed.
  void notifyChange() {
    // Incrementing the trigger value to notify Obx/ever listeners.
    refreshTrigger++;
  }
}