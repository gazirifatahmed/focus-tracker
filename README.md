# 🎯 Focus Tracker

> **Break bad habits. Build streaks. Earn badges. Stay motivated daily.**

Focus Tracker is a premium, beautifully crafted self-discipline and habit tracking mobile application. Whether you are fighting porn addiction (NoFap), quitting smoking, managing screen time, or building unbreakable daily routines, Focus Tracker is designed to help you reclaim your life—100% free, forever, and completely ad-free.

---

## 📸 App Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/7c5d9d6d-2ed9-468d-9da9-011908faedbb" width="230" alt="Home Screen" />
  <img src="https://github.com/user-attachments/assets/5c4068c2-5c7d-4c2f-a7a0-e93af31e7af7" width="230" alt="Progress Tracker" />
  <img src="https://github.com/user-attachments/assets/a6c98e2a-e6fc-4ed1-b3b4-d01673c8b838" width="230" alt="Inspiration Delivery" />
  <img src="https://github.com/user-attachments/assets/c4475398-9cd9-45c0-9688-f918393e245f" width="230" alt="History and Badges" />
</p>

---

## 🔥 Key Features

*   **🎮 Gamified Experience:** Track your journey down to the second. Your determination is rewarded in real-time.
*   **🏆 9 Exclusive Badges:** Stay motivated as you unlock iconic, progress-based badges:
    `Clown` ➡️ `Noob` ➡️ `Novice` ➡️ `Average` ➡️ `Advanced` ➡️ `Sigma` ➡️ `Chad` ➡️ `Absolute Chad` ➡️ `Giga Chad`.
*   **📅 Progress Logs & Journaling:** Log your setbacks with precise dates and short, constructive reasons (e.g., *Stress, Tired, Sickness*) to learn from your triggers.
*   **🔔 Real-Time Inspiration:** Get instant push notifications with motivational quotes and congratulations when you hit milestone streaks.
*   **☁️ Secure Cloud Sync:** Powered by Firebase. All your progress, streaks, and history are synced in real-time, ensuring you never lose your data.
*   **🌙 Premium Dark & Light UI:** A sleek, minimal, eye-friendly design tailored for deep focus.

---

## 🛠️ Tech Stack & Packages

Focus Tracker is built using **Flutter & Dart**, utilizing modern package architectures:

*   **State Management:** `provider`
*   **Backend & Sync:** `firebase_core`, `firebase_auth`, `cloud_firestore`
*   **Local Storage:** `shared_preferences`
*   **Notifications:** `firebase_messaging`, `flutter_local_notifications`
*   **Asset Management:** Native audio triggers (`audiolayers`), localized date-time tracking (`timezone`, `intl`)

---

## 🚀 Installation & Setup

Follow these steps to run the project locally:

### Prerequisites
*   Flutter SDK (v3.0.0 or higher)
*   Dart SDK (v3.0.0 to <4.0.0)
*   Android Studio / Xcode

### Local Setup

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/gazirifatahmed/focus-tracker.git](https://github.com/gazirifatahmed/focus-tracker.git)
   cd focus-tracker
Get dependencies:

Bash
flutter pub get
Firebase Setup:

Generate and place your google-services.json in android/app/

Generate and place your GoogleService-Info.plist in ios/Runner/

Run the App:

Bash
flutter run
📦 How to Build Release Bundle (.aab)
To generate the production-ready Android App Bundle for Google Play Store, execute:

Bash
flutter clean
flutter build appbundle
🤝 Contribution & Support
Contributions, issues, and feature requests are welcome! If you love this project, please give it a ⭐️ on GitHub to show your support.

Developed with ❤️ by Gazi Rifat Ahmed
