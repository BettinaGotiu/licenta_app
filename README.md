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
