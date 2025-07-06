📝 Flutter Firebase Note App
A simple note-taking app built with Flutter, Firebase Authentication, Cloud Firestore, and Bloc for state management.

📱 Features
✅ Sign up & Login using email and password

✅ Secure Firebase Authentication

✅ Add, Edit, Delete Notes (CRUD)

✅ Real-time sync with Firestore

✅ State management with flutter_bloc

✅ Snackbar feedback for all actions

✅ Clean UI and architecture

🚀 Getting Started
1. Clone the Repo
  
  
   git clone https://github.com/YOUR_USERNAME/flutter_note_app.git
   cd flutter_note_app
2. Install Dependencies
   
   flutter pub get
3. Firebase Setup
   Create a Firebase project

Enable Email/Password authentication

Enable Cloud Firestore

Download google-services.json and place it in android/app/

##4. Run the App
  
   flutter run
   ✅ Works on emulator or real device (not supported on web for this assignment).

 ##Folder Structure##

lib/
├── cubit/         # Bloc state management
├── models/        # Data models
├── screens/       # UI screens
├── services/      # Firebase services
└── main.dart      # App entry
