<h1 align="center">ClearTalk</h1>

## 📂 Source Code

The full source code of the ClearTalk mobile application is available on GitHub:  
🔗 [GitHub Repository – ClearTalk](https://github.com/BettinaGotiu/licenta_app)

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
