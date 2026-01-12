# 🐷 Piggy Log (v1.3.0)

![Piggy Log Banner](./docs/metadata/piggy_log_image.png)

> 🚀 **Major Milestone**: Strategic architectural migration from GetX to **Provider** and implementation of a **4-Layered Architecture**.

**Piggy Log** is a production-grade personal finance application available on [App Store](https://apps.apple.com/app/piggy-log/id6757284836) and [Google Play](https://play.google.com/store/apps/details?id=com.terry.piggyLog). It focuses on **data integrity, architectural scalability, and global usability.**

---

## 🏗️ Architectural Evolution: Why We Migrated

Version 1.3.0 marks a significant pivot in the project's engineering philosophy. After visualizing the system's complexity, we replaced GetX with **Provider** to achieve:

* **Predictable State Management**: Moving from implicit dependency injection to an explicit, compiler-safe structure.
* **Separation of Concerns**: Implementing a 4-layered architecture to decouple business logic from the UI.
* **Maintenance Efficiency**: Reducing technical debt by simplifying complex data flows and improving traceability.

---

## 📲 Download Now

<p align="left">
  <a href="https://apps.apple.com/app/piggy-log/id6757284836">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="40" style="vertical-align: middle;" alt="Download on App Store">
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.terry.piggyLog">
    <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="60" style="vertical-align: middle; margin-left: 10px;" alt="Get it on Google Play">
  </a>
</p>

*Experience **Piggy Log** today! Check out our live production app on both the App Store and Google Play.*

---
---

## 🛠️ Technical Design Documents

Click the links below to view the detailed design blueprints of Piggy Log.

### 1. [Logical Architecture](./docs/logical_architecture.png)
* **Pattern**: 4-Layered Architecture (`Service` → `Repository` → `Provider` → `View`).
* **Highlight**: Visualizes how global configuration (Settings) reactively influences the entire UI system through a centralized state.

### 2. [Conceptual ERD](./docs/conceptual_ERD.png)
* **Focus**: High-level business logic and entity relationships (`Category`, `Record`, `Budget`).
* **Purpose**: Defined the initial data blueprint to ensure solid and accurate financial tracking logic.

### 3. [Physical DB Schema](./docs/physical_db_schema.png)
* **Implementation**: SQLite (sqflite) schema with strict data typing and Foreign Key constraints.
* **Optimization**: Designed for high-performance local data persistence and robust relational data integrity.

---

## 📂 Project Roadmap & Structure

The project follows a **Feature-Based Architecture**, grouping code by functional modules to maximize scalability and developer experience.

```text
lib/
├── core/                # Infrastructure (Database, Global Utils, Shared Widgets)
├── data/                # Data Layer (Models, Physical Data Entities)
├── features/            # Feature-centric modules (Calendar, Dashboard, Onboarding)
├── providers/           # App-wide State Management (Logic & ViewModels)
├── l10n/                # Localization (EN, KO, JA, TH)
└── main.dart            # Entry Point & Theme Configuration
```

🌟 Key Features
🌍 Global Localization: Full support for English, Korean, Japanese, and Thai.

📊 Visual Analytics: Refined Radar Charts and budget tracking using fl_chart.

⭐ Production Quality: Integrated native In-App Review system and intuitive Onboarding flow.

💾 Solid Persistence: Professional-grade SQLite integration for reliable and secure data storage.

📬 Contact & Developer
Terry Yoon – Mobile Developer

📧 yonghyuk.terry.yoon@gmail.com | 📍 Vancouver, BC, Canada

This project demonstrates a transition from rapid prototyping to professional software engineering standards.