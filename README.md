# 🎓 Online Examination & AI Proctoring System

[![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)](https://www.oracle.com/java/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Tomcat](https://img.shields.io/badge/Apache_Tomcat-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black)](https://tomcat.apache.org/)
[![Live Demo](https://img.shields.io/badge/Live_Demo-Online-brightgreen?style=for-the-badge)](https://online-test-web-application-7mu3.onrender.com/)

A production-grade, secure, and AI-enhanced Online Examination System designed to modernize the assessment lifecycle. This platform integrates advanced proctoring, anti-cheating mechanisms, and interactive question types to ensure academic integrity in digital learning environments.

![Project Screenshot](https://raw.githubusercontent.com/Siphelele-Maphumulo/Senior_Portfolio/refs/heads/main/assets/images/project/Screenshot%202026-02-17%20102101.png?token=GHSAT0AAAAAADWGU3JKGKLGVEWP5OM4LNC22NLBOVQ)

---

## 🔗 Quick Links
- 🌐 **[Live Demo](https://online-test-web-application-7mu3.onrender.com/)**
- 📚 **[Documentation](#-features)**
- 🛠️ **[Installation Guide](#-getting-started)**
- 🛡️ **[Security Policy](SECURITY.md)**

---

## 📖 Table of Contents
1. [About the Project](#-about-the-project)
2. [Key Features](#-key-features)
3. [Interactive Question Types](#-interactive-question-types)
4. [Architecture](#-architecture)
5. [Tech Stack](#-tech-stack)
6. [Getting Started](#-getting-started)
7. [Security](#-security)
8. [Contributing](#-contributing)
9. [Future Roadmap](#-future-roadmap)

---

## 🎯 About the Project
Traditional examination processes often suffer from administrative overhead and security vulnerabilities. This project provides a robust solution by automating the entire examination lifecycle while maintaining high standards of integrity through AI-driven monitoring.

Originally developed to address challenges in South African education, it is designed for scalability, allowing institutions to manage thousands of students, diverse course structures, and complex assessment types within a single, unified dashboard.

---

## 🚀 Key Features

### 🤖 AI-Powered Proctoring
- **Face Detection & Verification**: Real-time monitoring using `face-api.js` to ensure the candidate stays on screen.
- **Identity Verification**: Multi-stage identity check including face and ID card analysis powered by OpenAI models via OpenRouter.
- **Environment Scanning**: AI-driven detection of unauthorized objects and behavior monitoring.

### 🛡️ Advanced Anti-Cheating System
- **Refresh Prevention**: Blocks F5, Ctrl+R, and right-click menus during active exams.
- **Tab/Window Switching Detection**: Automatically tracks when a student leaves the exam window and initiates a warning/termination countdown.
- **Navigation Blocking**: Disables back/forward navigation to keep the user within the assessment environment.
- **Violation Logging**: Every suspicious activity is logged in the `exam_violations` table for post-exam auditing.

### 📊 Comprehensive Administration
- **Role-Based Access Control (RBAC)**: Secure dashboards for Admins, Lecturers, and Students.
- **Dynamic Question Bank**: CRUD operations for multiple question types, including image support.
- **Real-time Analytics**: Instant grading and performance reports for both students and instructors.

---

## 🧩 Interactive Question Types
The system supports a variety of assessment methods beyond standard Multiple Choice:
- **Drag & Drop**: Matching items to targets using a modern, intuitive interface.
- **Rearrange**: Sequential ordering questions where items must be placed in a specific order.
- **True/False & Multi-Select**: Flexible formats for diverse subject matter.

---

## 🏗️ Architecture
The system follows a refined Model-View-Controller (MVC) pattern for Java Web Applications.

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│     Client      │      │   Controller    │      │    Database     │
│ (JSP/JS/CSS)    │ ───▶ │ (controller.jsp)│ ───▶ │ (MySQL Server)  │
└─────────────────┘      └─────────────────┘      └─────────────────┘
         ▲                        │                        │
         └────────────────────────┴────────────────────────┘
```

### Data Model
The system uses a robust relational schema:
- **Users & Roles**: Manages students, lecturers, and admins.
- **Courses & Questions**: Relational question bank with support for interactive types.
- **Exams & Answers**: Tracks attempts, saves progress in real-time, and stores detailed results.
- **Proctoring Logs**: Dedicated tables for identity verification and incident reporting.

---

## 🛠️ Tech Stack

| Category | Technology |
| :--- | :--- |
| **Backend** | Java (JSP), Servlet API |
| **Database** | MySQL 8.0+ |
| **AI/Vision** | OpenAI (GPT-4o via OpenRouter), face-api.js |
| **Frontend** | HTML5, CSS3, JavaScript (ES6+) |
| **Server** | Apache Tomcat 8.5+ |
| **Security** | jBCrypt Hashing, Session Management |

---

## 📦 Getting Started

### Prerequisites
- **JDK 8+**
- **MySQL 8.0+**
- **Apache Tomcat 8.5+**
- **Apache Ant** (Build tool)

### Installation
1. **Clone the Repository**
   ```sh
   git clone https://github.com/Siphelele-Maphumulo/Online-Test-Web-Application.git
   cd Online-Test-Web-Application
   ```

2. **Database Configuration**
   - Create a database named `exam_system`.
   - Import the schema from `db script/`. Run `exam_system.sql` first, followed by any specialized scripts like `create_drag_drop_table.sql`.
   - Configure credentials in `src/java/myPackage/DatabaseClass.java` (or via `config/secrets.properties` if using the updated security config).

3. **API Keys (OpenRouter)**
   - Copy `openrouter.properties.example` to `openrouter.properties`.
   - Add your `OPENROUTER_API_KEY`.

4. **Build & Deploy**
   - Use `ant dist` to generate the `.war` file.
   - Deploy the `.war` to your Tomcat `webapps` directory.

---

## 🛡️ Security
Security is a core pillar of this application.
- **No Secrets in Git**: Sensitive data is managed via `.properties` and `.env` files ignored by version control.
- **Password Protection**: Industry-standard jBCrypt hashing.
- **Session Integrity**: Secure session handling to prevent hijacking.

See **[SECURITY.md](SECURITY.md)** for full configuration details.

---

## 🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🚀 Future Roadmap
- [ ] **Mobile App**: Native Android/iOS applications for remote testing.
- [ ] **LMS Integration**: LTI compliance for integration with Canvas/Moodle.
- [ ] **Advanced Analytics**: Predictive performance modeling.

---

## 📄 License
Distributed under the MIT License.

---
**Maintained by [Siphelele Maphumulo](https://github.com/Siphelele-Maphumulo)**
