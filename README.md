# Robo Cell

Welcome to the official application for the **Robo Cell** at Bangalore Institute of Technology (Department of Robotics & Artificial Intelligence). 

This application serves as the central hub for our members, providing real-time updates on committees, upcoming meetings, events, and broadcast feeds, all wrapped in a premium, dark-mode focused UI.

## Features

- **Centralized Hub:** View active committees, member directories, and current projects.
- **Real-Time Feed:** Stay updated with the latest announcements and broadcast posts.
- **Meeting Tracking:** Seamlessly check schedules and agendas for upcoming cell meetings.
- **True Offline Support:** Powered by aggressive local caching. The app works flawlessly without an internet connection once data is synced.
- **Premium UI/UX:** A stunning, fully custom dark mode interface with smooth shimmer loading states and scalable vector graphics.

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend as a Service:** [Supabase](https://supabase.com/) (Authentication & Database)
- **Local Storage / Caching:** [Hive](https://docs.hivedb.dev/) & `cached_network_image`
- **State Management:** `provider`

## Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0)
- Dart SDK
- Supabase Project (if running your own backend instance)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Tejashj/robo_cell.git
   cd robo_cell
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Environment Variables:**
   Create a `.env` file in the root of the project and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```
   *(Note: The `.env` file is safely excluded from version control.)*

4. **Run the App:**
   ```bash
   flutter run
   ```

## Open Source & Contributions

**Robo Cell is an Open Source project, and contributions are warmly welcomed!** 

Whether you want to fix a bug, improve the UI, or propose a completely new feature, we'd love to see your pull requests. 

### How to Contribute
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'feat: added an amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

Please ensure your code follows standard Flutter linting rules and maintains the existing dark-mode aesthetics of the app.

---
*Built with ❤️ by Tech Tryanuka*
