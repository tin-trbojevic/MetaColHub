# MetaColHub

MetaColHub is a **cross-platform Flutter application** developed as my **Final Project (Završni rad)** at the **Faculty of Informatics and Digital Technologies (FIDIT), University of Rijeka**.

The app is designed for working with **collocations** stored in CSV files, enabling users to efficiently manage linguistic data.

---

## Features

- **Cross-platform support**: Works on Windows, macOS, Android, and iOS  
- **CSV file handling**: Upload and manage files with the required format: **base;collocation;example**
- **Firebase integration**:
  - **Authentication** – secure login/register/forgot password  
  - **Cloud Firestore** – storing and managing collocations online  
- **Collocation management**:
  - Add, edit, delete collocations in specific files  
  - Search collocations across all uploaded files  
  - View collocations grouped by base with examples  
- **Dark mode support** – seamless switch between light and dark themes  
---

## Project structure

- `lib/` – main Flutter source code  
- `components/` – reusable UI widgets (dialogs, drawers, etc.)  
- `services/firestore_service.dart` – Firebase and Firestore logic  
- `screens/` – all app screens (Login, Register, Home, Detail, Profile, Settings, etc.)

---

## Screenshots

<p float="left">
  <img width="45%" alt="Home" src="https://github.com/user-attachments/assets/abaff549-c976-45ea-821d-2be99e404d6b" />
  <img width="45%" alt="Detail" src="https://github.com/user-attachments/assets/19907826-db3a-4910-8e41-3520f3774fbe" />
</p>

<p float="left">
  <img width="45%" alt="Profile" src="https://github.com/user-attachments/assets/355e465d-8fc4-4e04-aa39-9c38a9b1a514" />
  <img width="45%" alt="DarkMode" src="https://github.com/user-attachments/assets/6c562468-5ef4-437e-9672-3ea750ca92e3" />
</p>

---
