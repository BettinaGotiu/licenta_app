<h1 align="center">ClearTalk</h1>

## 📂 Source Code

The full source code of the ClearTalk mobile application is available on GitHub:  
🔗 [GitHub Repository – ClearTalk](https://github.com/BettinaGotiu/licenta_app)

## 📌 Scope

**ClearTalk** is a mobile application designed to help users practice and improve their public speaking skills.  
It provides real-time analysis of spoken content, focusing on pace, filler word detection, and performance tracking.

## 🚀 Main Functionalities

- User authentication (Sign up / Log in)
- Real-time speech-to-text transcription
- Detection and highlighting of filler words (e.g., "um", "so", "basically")
- Visual pacing feedback using color-coded indicators
- Custom word tracking (e.g., personal speech tics)
- Exercise prompts and daily speaking challenges
- Session history, statistics, and progress graph
- Streak tracking and calendar highlighting
- Transcript review with bolded filler words
- Cloud storage using Firebase
- Help buttons integrated throughout the UI


## 🛠️ Technologies Used

- **Flutter** (Cross-platform app framework)
- **Firebase** (Authentication, Firestore, Storage)
- **speech_to_text** (for voice transcription)
- **charts_flutter / mrx_charts** (for data visualization)
- **table_calendar** (for calendar-based streak tracking)

## ⚙️ Local Setup Instructions

```bash
# Clone the repo
git clone <repo-url>
cd licenta_app

# Install dependencies
flutter pub get

# Build the application
flutter build

# NOTE: Add your Firebase configuration files:
# - google-services.json (for Android)
# - GoogleService-Info.plist (for iOS, if needed)

# Run the app
flutter run
```
# 🔑 Firebase Configuration Guide

In order to run **ClearTalk** and access the real-time database, users must configure Firebase locally by adding a `google-services.json` file to the project.

---

## 📁 Setup Instructions

1. **Go to [Firebase Console](https://console.firebase.google.com/).**

2. **Create a new project** or request access to the existing project (for contributors).

3. **Navigate to:**  
   _Project Settings_ → _Your Apps_ → **Add Android app**

4. **Register your app** using this package name:
   ```
   com.example.licenta_app
   ```

5. **Download** the generated `google-services.json` file.

6. **Place the file in your project at:**
   ```
   android/app/google-services.json
   ```

---

## 🧩 Example: Minimal `google-services.json` Template

> _This is a **template/minimal example** — do not include real API keys or OAuth tokens in public repositories._

```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_MOBILESDK_APP_ID",
        "android_client_info": {
          "package_name": "com.example.licenta_app"
        }
      }
    }
  ],
  "configuration_version": "1"
}
```


## ✅ Automatic Database Setup

Once the app is running and a user creates an account, all required collections and documents are automatically created in Firestore — _no manual database setup needed!_

This includes:

- `users` collection with individual user documents
- `sessions` subcollections for each user
- `settings` documents, progress tracking, and more

---

#### ➡️ Make sure you have either:

- An Android emulator 

- A physical Android device connected via USB with Developer Mode enabled
  
## 🌍 SCMUPT Participation 

ClearTalk won **1st place** at **SCMUPT 2025**, the 13th edition of the annual *Mobile Apps Communication Session* hosted by the **Faculty of Automation and Computers**, *Politehnica University of Timișoara*.

The competition encourages students to develop impactful mobile applications across two categories:  
**Utility & Lifestyle** and **Community, Entertainment & Games**.

---

### 🔗 Useful Links

- 📊 [SCMUPT 2025 Results](https://sites.google.com/view/scmupt/home?authuser=0)  
- 🎥 [Interview & Demo Video](https://www.youtube.com/watch?v=ccrvT67X5Fo)
- 📱 [Watch the Full Demo](https://github.com/BettinaGotiu/licenta_app/blob/main/ClearTalk_Demo.mp4)
