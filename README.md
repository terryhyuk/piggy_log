# 🐷 Piggy Log

![Piggy Log Banner](./docs/metadata/piggy_log_image.png)

> 🚀 **Update (2025-12-30)**: **Official Launch!** Piggy Log is now available on the App Store and Google Play.
> 🏗️ **Ongoing**: Currently refactoring to **Feature-based Architecture** to enhance scalability for version 1.3.0.

<p align="center">
  <strong>Flutter Developer Project – Cross-Platform Expense Tracker with Multi-Language Support</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" />
  <img src="https://img.shields.io/badge/GetX-892CA0?style=for-the-badge&logo=getx&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
</p>

**Piggy Log** is a professional-grade personal finance application built with **Flutter**.  
It is designed for users who value **simplicity, data privacy (offline-first storage), and seamless usability across multiple regions**.

> ⚡ **For Recruiters**: Production-ready app featuring high-performance charts, 4-language localization, and a robust local database.  
> 🛠 **For Engineers**: Currently undergoing a strategic transition from a lightweight MVVM to a **Modular Layered Architecture** to improve scalability, maintainability, and developer experience.

---

## 🌟 Key Features

* **🌍 Global Localization** – English, Korean, Japanese, and Thai
* **💰 Budget Management** – Set and track monthly financial goals with real-time category analysis
* **📊 Data Visualization** – Interactive charts with `fl_chart`
* **📅 Calendar Integration** – Browse transactions via intuitive calendar view
* **🎨 Personalization** – Custom categories, icons, and dynamic themes

---

## 📲 Official App Store Preview

<p align="center">
  <img src="./docs/metadata/app_store_preview.jpg" width="100%" alt="Piggy Log App Store Preview" />
</p>

*The UI/UX has been fully optimized for a premium financial tracking experience.* 🍎

---

## 📲 Download Now

<a href="https://apps.apple.com/app/piggy-log/id6757284836">
  <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="50">
</a>
*Experience **Piggy Log** today! Check out our live production app on the App Store.*

---

## 📂 Engineering Roadmap: Architectural Evolution

To ensure the project scales efficiently, the app is being refactored from a lightweight MVVM into a **Modular Layered Architecture**.

### Phase 1 – Current Lightweight MVVM

```text
lib/
├── controller/  # Reactive UI state management (GetX)
├── l10n/        # Localization files (EN, KO, JA, TH)
├── model/       # Data entities & mapping
├── view/        # UI screens and shared components
└── VM/          # ViewModels & SQLite Database Handlers
```

Planned Modular Layered Architecture 🚀
Directory	Responsibility	Why This Change?
lib/state/	GetX Controllers	Isolate reactive states from business logic
lib/services/	Logic & DB Repositories	Decouple persistence layers for easier maintenance
lib/models/	Data Entities (PODOs)	Ensure data integrity across the app
lib/screens/	Page-level Widgets	Simplify navigation and top-level layouts
lib/widgets/	Atomic UI Components	Maximize code reuse and reduce redundancy

This refactor prioritizes Separation of Concerns, making the codebase cleaner for team collaboration and future cloud-sync integrations.

🏗 Technical Design & Modeling
1. Logical Data Flow (System Design)
Mapped using Miro to visualize and ensure clear business logic before implementation.



2. Database Schema (ERD)
Designed with ERDCloud to enforce strict relational integrity in SQLite.



Referential Integrity: 1:N Foreign Key constraints

Precision: SQLite REAL for financial accuracy, TEXT for ISO dates

⚠️ ERD will be updated after database normalization and metadata expansion

3. System Flow Diagram (SFD)
Visualizes reactive interactions between UI, GetX Controllers, and Database Handlers.



⚠️ Architecture diagram will be updated post-refactor to reflect the new Service-Layered model

🛠 Tech Stack
Framework: Flutter (iOS & Android)

State Management: GetX (Reactive)

Database: SQLite via sqflite

Charts: fl_chart

Calendar: table_calendar

Localization: intl

Modeling Tools: Miro (Logic), ERDCloud (DB), Figma (UI), Canva (Assets)

IDE: VS Code

💡 Technical Challenges & Solutions
Challenge: Maintaining consistent data types between SQLite (dynamic typing) and Dart (static typing)

Solution: Refactored DatabaseHandler to implement a strict mapping layer, ensuring financial values (double) are handled without rounding errors

📬 Contact
Terry Yoon – Mobile Developer
📧 yonghyuk.terry.yoon@gmail.com
📍 Vancouver, BC, Canada

💡 North American recruiters: This project demonstrates cross-platform Flutter development, multi-language support, clean and maintainable code, and database integration.
