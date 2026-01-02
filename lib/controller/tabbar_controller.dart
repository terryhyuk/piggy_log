import 'package:get_x/get.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent:
//    Manages global navigation state and contextual interaction modes.
//    Ensures a seamless transition between features by sanitizing UI states
//    (e.g., exiting edit mode) when the user navigates across tabs.
// -----------------------------------------------------------------------------

class TabbarController extends GetxController {
  
  // 1. Reactive Navigation State:
  // Tracks the currently active index for the bottom navigation bar.
  var index = 0.obs;
  
  // 2. Page-Specific Interaction State:
  // Controls the 'Edit Mode' toggle for the category management screen.
  var isCategoryEditMode = false.obs;

  /// Updates the active tab index and resets temporary UI states.
  void changeTabIndex(int newIndex) {
    
    // [UX Sync] State Cleanup Logic:
    // If navigating away from the 'Categories' tab (index 1),
    // force-disable the edit mode to ensure a consistent UX upon return.
    if (index.value == 1) {  
      isCategoryEditMode.value = false;
    }
    
    // Update the observable index to trigger reactive UI updates.
    index.value = newIndex;
  }
}