<h1 align="center">ClearTalk</h1>

## 📂 Cod Sursă

Codul sursă complet al aplicației mobile ClearTalk este disponibil pe GitHub:  
🔗 [Repository GitHub – ClearTalk](https://github.com/BettinaGotiu/licenta_app)

## ⚙️ Instrucțiuni pentru Instalare Locală

```bash
# Clonează repo-ul
git clone <repo-url>
cd licenta_app

# Instalează dependențele
flutter pub get

# Compilează aplicația
flutter build

# NOTĂ: Adaugă fișierele tale de configurare Firebase:
# - google-services.json (pentru Android)
# - GoogleService-Info.plist (pentru iOS, dacă este nevoie)

# Pornește aplicația
flutter run
```
# 🔑 Ghid Configurare Firebase

Pentru a rula **ClearTalk** și a accesa baza de date în timp real, utilizatorii trebuie să configureze local Firebase, adăugând un fișier `google-services.json` în proiect.

---

## 📁 Instrucțiuni de Configurare

1. **Accesează [Firebase Console](https://console.firebase.google.com/).**

2. **Creează un proiect nou** sau cere acces la proiectul existent (pentru colaboratori).

3. **Navighează la:**  
   _Project Settings_ → _Your Apps_ → **Add Android app**

4. **Înregistrează aplicația** folosind acest nume de pachet:
   ```
   com.example.licenta_app
   ```

5. **Descarcă** fișierul `google-services.json` generat.

6. **Plasează fișierul în proiect la:**
   ```
   android/app/google-services.json
   ```

---

## 🧩 Exemplu: Șablon Minimal `google-services.json`

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

## ✅ Configurare automată a bazei de date

După ce aplicația rulează și un utilizator își creează un cont, toate colecțiile și documentele necesare sunt create automat în Firestore — _nu este nevoie de configurare manuală a bazei de date!_

Acest lucru include:

- colecția `users` cu documente individuale pentru fiecare utilizator
- subcolecțiile `sessions` pentru fiecare utilizator
- documente de tip `settings`, urmărirea progresului și altele

---

#### ➡️ Asigură-te că ai fie:

- Un emulator Android 

- Un dispozitiv Android fizic conectat prin USB, cu Modul de Dezvoltator activat
  
## 🌍 Participarea la SCMUPT 

ClearTalk a câștigat **locul 1** la **SCMUPT 2025**, ediția a 13-a a *Mobile Apps Communication Session* organizată de **Facultatea de Automatică și Calculatoare**, *Universitatea Politehnica Timișoara*.

Competiția încurajează studenții să dezvolte aplicații mobile cu impact în două categorii:  
**Utilitate & Stil de viață** și **Comunitate, Divertisment & Jocuri**.

---

### 🔗 Linkuri Utile

- 📊 [Rezultate SCMUPT 2025](https://sites.google.com/view/scmupt/home?authuser=0)  
- 🎥 [Interviu & Video Demo](https://www.youtube.com/watch?v=ccrvT67X5Fo)
- 📱 [Urmărește Demo-ul Complet](https://github.com/BettinaGotiu/licenta_app/blob/main/ClearTalk_Demo.mp4)
