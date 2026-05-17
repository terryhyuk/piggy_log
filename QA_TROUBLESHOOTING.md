# 🛠️ Piggy Log – QA & Technical Troubleshooting Log (13+ Cases)

This log documents the systematic analysis, reproduction, and verification of **13+ critical defect cases** identified during the software development life cycle (SDLC) of **Piggy Log**. It demonstrates a root cause analysis (RCA) approach and cross-platform verification strategies from a **QA Engineer's perspective**.

---

## 🔍 SECTION 1: Major Architectural & Logic Defect Cases (Deep Dive)

### 🐛 #01. State Management & Real-Time UI Synchronization
* **Context:** 상태 관리 및 실시간 UI 동기화 문제
* **Symptoms:** When global configurations (such as monthly budget limits or localized currency formats) were altered in the settings menu, the main dashboard and visual charts failed to update immediately. Changes only reflected after a hard application restart.
* **Root Cause:** Configuration change events were not being propagated down the widget tree because values were calculated exclusively during the initial widget initialization lifecycle (`initState`).
* **Resolution:** Refactored the state flow architecture from GetX to **Provider** to enforce an explicit data-binding pipeline, reducing implicit dependency bugs while locking global state updates.
* **QA Verification Perspective:** * Designed regression checks focusing on screen transitions and state retention after deep-nesting navigation.
  * Verified edge cases by executing rapid, consecutive setup inputs to ensure the UI and state-controllers remained in sync under heavy stress.

---

### 📅 #02. Time-Sensitive Data Integrity
* **Context:** 날짜 기준 로직 충돌 해결
* **Symptoms:** Selecting specific calendar dates occasionally fetched incorrect financial records, or data from the previous month leaked into the current view during calendar grid navigation.
* **Root Cause:** A data mismatch occurred between the database and the client application. The local SQLite database stored dates as string formats (`yyyy-MM-dd`), whereas the front-end application compared them using complete runtime `DateTime` objects, introducing time-zone and timestamp evaluation errors.
* **Resolution:** Standardized and normalized all date-matching queries and validation logic into uniform `yyyy-MM-dd` string literals at the data source layer before parsing to the UI layer.
* **QA Verification Perspective:**
  * Formulated a comprehensive boundary value analysis matrix handling data rendering across month-ends, leap years, and specific local time-zone shifts.
  * Audited SQLite storage snapshots directly to confirm that modified transaction stamps retained strict structural data integrity.

---

### 🗄️ #03. Multi-Entry Architecture Data Integrity Conflict
* **Context:** 데이터 무결성 유지
* **Symptoms:** After editing a transaction on the calendar page, the record disappeared completely from the specific category breakdown list view.
* **Root Cause:** The SQL query in the local `CalendarHandler` was missing the `c_id` (Category ID) column, causing the category attribute to reset to `0` during updates.
* **Resolution:** Modified the SQL query to fetch all required relational columns (`SELECT *`) and reinforced the object mapping data integrity layers.
* **QA Verification Perspective:**
  - Performed cross-page data consistency sweeps across the calendar, dashboard, and category-specific fragments simultaneously post-update.
  - Assured zero-loss object data persistence on sudden layout terminations during database write operations.

---

### 💱 #04. Currency Formatting Presentation Scatter
* **Context:** 통화 및 포맷팅 로직 일관성 유지
* **Symptoms:** Currency symbols and number separators were inconsistent across different contextual screens, causing critical user confusion.
* **Root Cause:** Presentation formatting logic was scattered across multiple separate widgets, leading to partial updates when user preferences changed.
* **Resolution:** Centralized formatting logic into a dedicated utility class and ensured all widgets retrieve formats from a single source of truth (`SettingsController`).
* **QA Verification Perspective:**
  - Tested layout presentation uniformity under varying display languages to ensure symbols aligned correctly with dynamic numbers.
  - Validated that changing configurations from the deep settings menu instantly triggered updates across all open background pages.

---

## 📝 SECTION 2: Structural & Component-Level Defect Logs (Defect Registry)

### 🌐 #05. Localization Layout Breaches
* **Context:** 다국어 지원 반응형 레이아웃 대응
* **Defect:** Switching the application locale to English or Japanese caused structural text overflows, component breakage, and clipped buttons, rendering critical UI elements invisible.
* **Root Cause:** Layout specifications implemented fixed-width framing parameters optimized solely for standard Korean character lengths, preventing dynamic component scaling based on text expansion.
* **Resolution:** Eradicated fixed dimensions across text containers and integrated dynamic layouts utilizing `Flexible` and `Expanded` architectural widgets to accommodate dynamic text sizes seamlessly.

---

### 📊 #06. Data Visualization Optimization
* **Context:** 데이터 시각화 최적화 (`fl_chart` & 다크모드)
* **Defect:** Chart labels were clipped off-screen, and graphs were difficult to read in Dark Mode due to low color contrast.
* **Root Cause:** Relied too heavily on default library settings without implementing theme-specific color logic or sufficient padding boundaries.
* **Resolution:** Adjusted chart paddings and applied distinct, high-contrast color palettes for both Light and Dark modes.

---

### 🏗️ #07. Component Refactoring Integrity Breakdown
* **Context:** 구성 요소 리팩토링 과정의 구조적 무결성
* **Defect:** Features stopped working or data flows became broken during the process of refactoring and isolating monolithic widgets into modular components.
* **Root Cause:** Widgets held core business logic internally, causing data paths or controller references to be lost when structural elements were separated.
* **Resolution:** Stabilized architecture by migrating all core logic into Controllers, strictly enforcing the *Separation of Concerns* to limit widgets to pure UI rendering.

---

### 🔋 #08. Background Resource Leaks
* **Context:** 지속적인 애니메이션 리소스 누수 관리
* **Defect:** Device temperature spikes and battery drainage increased significantly when the application remained idle or minimized in the background.
* **Root Cause:** Context-specific shake animations designed for micro-interactions failed to pause when navigating away; the animation controller remained active off-screen, consuming unnecessary CPU processing ticks.
* **Resolution:** Integrated widget lifecycle management states (`WidgetsBindingObserver`) alongside dynamic tab-index monitoring to explicitly freeze, stop, or dispose of rendering animation tracks whenever the container is obscured.

---

### 🧹 #09. Debugging Build Failures: Naming Conventions & Resource Cleaning
* **Context:** 디버깅 빌드 실패: 명명 규칙 및 리소스 클리닝
* **Defect:** Encountered repeated build failures and broken icons on the simulator after adding new icon assets into the project.
* **Root Cause:** Resource filenames violated Android’s asset naming conventions by containing uppercase letters and invalid special characters, while outdated build artifacts remained cached.
* **Resolution:** Renamed all assets to follow the strict lowercase and underscore (`snake_case`) convention and executed a thorough `flutter clean` to ensure a fresh build from scratch.

---

### 📱 #10. Strict Platform Requirements for App Icons
* **Context:** 앱 아이콘 플랫폼 규정 준수 예약어
* **Defect:** The custom app launcher icon failed to display correctly or caused build configuration crashes when assigned an arbitrary filename like `icon.png`.
* **Root Cause:** The Android system and `AndroidManifest.xml` expect the main launcher icon asset to follow a specific reserved naming convention (`ic_launcher`). Deviating from this standard caused resource map mismatches.
* **Resolution:** Renamed the asset configurations to the standard `ic_launcher.png` and explicitly synchronized mapping references inside the XML application blocks.

```xml
<application
    android:label="Piggy Log"
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher">
</application>
```

🪙 #11. Dynamic Locale-Based Currency Formatting
Context: 통화 계산 로직 예외 처리 / Zero-Decimal Logic

Defect: Selecting South Korean Won (KRW) or Japanese Yen (JPY) caused the app to display unnecessary decimal points (e.g., ₩1,000.00 instead of ₩1,000), violating local currency conventions.

Root Cause: The NumberFormat.currency constructor defaulted to the system locale's basic decimal configurations (2 digits) without evaluating specific currency trait parameters.

Resolution: Implemented dynamic formatting logic to explicitly evaluate the currency code and force decimalDigits to 0 for zero-decimal environments.

```xml
// [Before] Static formatting regardless of currency type
currencyFormat = NumberFormat.currency(locale: localeStr, symbol: symbol); // Result: ₩1,200.00

// [After] Dynamic formatting based on currency code
int decimalDigits = (code == 'KRW' || code == 'JPY') ? 0 : 2;
currencyFormat = NumberFormat.currency(
  locale: localeStr, 
  symbol: symbol, 
  decimalDigits: decimalDigits, // Explicitly control decimal places
); // Result: ₩1,200
```

🛡️ #12. Runtime Null Safety in Currency Data Mapping
Context: 런타임 널 안정성

Defect: The application crashed instantly via a Null Pointer Exception when users selected a newly introduced localization tracking configuration like "Thai Baht (THB)".

Root Cause: A data map key mismatch occurred where the UI provided an input token that did not exist in the back-end controller asset map yet, causing a crash due to an unsafe ! (null assertion) operator.

Resolution: Synchronized the data model matrices and implemented safe null-coalescing mappers (??) to guarantee solid fallback paths under structural runtime anomalies.


```xml
// [Before] Missing data key and unsafe null assertion
final currencies = { 'USD': {...}, 'KRW': {...} }; 
final data = currencies[currencyCode]!; // CRASH when currencyCode is 'THB'

// [After] Synchronized data map with null safety fallback
final currencies = { 
  'USD': {...}, 
  'THB': {'symbol': '฿', 'code': 'THB'}, 
  'KRW': {...} 
};
final data = currencies[currencyCode] ?? currencies['USD']!; // Robust fallback protection
```

🔀 #13. Structural Refactoring: Ternary to Switch Expressions
Context: 구조적 개선 및 예외 케이스 처리

Defect: As international multi-language variations scaled up (EN, KO, JA, TH), highly nested inline ternary conditional logic became unreadable, chaotic, and heavily error-prone.

Root Cause: Overuse of inline branching operators (? :) for complex multi-case structural routing actions ruined file readability and maintainability.

Resolution: Refactored the core localization assignment architectures by adapting modern, flattened Dart switch expressions to ensure smooth system scalability.

Dart
// [Before] Hard-to-read nested ternary operators
final String localeStr = lang == 'ko' ? 'ko_KR' : lang == 'ja' ? 'ja_JP' : lang == 'th' ? 'th_TH' : 'en_US';

// [After] Clean and scalable Switch Expressions (Dart 3.0+)
final String localeStr = switch (lang) {
  'ko' => 'ko_KR',
  'ja' => 'ja_JP',
  'th' => 'th_TH',
  _ => 'en_US', 
};
