import 'package:flutter/material.dart';
import '../../schedule/screens/schedule_agenda_screen.dart';
import '../../schedule/screens/add_schedule_screen.dart';
import 'profile_screen.dart';

// Helper transisi rute geser ala Telegram untuk halaman baru
Route createTelegramRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
      );
    },
  );
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Index 2 adalah Tab Home di tengah
  int _currentIndex = 2;
  final ValueNotifier<int> _refreshTrigger = ValueNotifier<int>(0);

  late final PageController _pageController;
  late final List<Widget> _screens;

  final List<String> _titles = const [
    'Notion Lite',
    'NotebookLM Lite',
    'AI Hub',
    'Custom Jadwal',
    'Agenda & Alarm',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const _PlaceholderScreen(title: 'Notion Lite', icon: Icons.description_outlined),
      const _PlaceholderScreen(title: 'NotebookLM Lite', icon: Icons.auto_stories_outlined),
      const _HomeScreenPlaceholder(),
      const _PlaceholderScreen(title: 'Custom Jadwal', icon: Icons.calendar_month_outlined),
      ScheduleAgendaScreen(refreshTrigger: _refreshTrigger),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshTrigger.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  // Pop-up menu ringkas mekar di atas tombol (+)
  void _showCreateDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 198),
            child: Material(
              color: Colors.white,
              elevation: 8,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 235),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPopupItem(
                        icon: Icons.alarm_add_rounded,
                        color: const Color(0xFF6D28D9),
                        title: 'Buat Alarm Jam',
                        onTap: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            createTelegramRoute(const AddScheduleScreen()),
                          );
                          if (result == true) {
                            _onTabTapped(4); // Pindah ke tab Alarm
                            _refreshTrigger.value++;
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 40, endIndent: 8),
                      _buildPopupItem(
                        icon: Icons.calendar_today_rounded,
                        color: Colors.blueAccent,
                        title: 'Buat Jadwal Kalender',
                        onTap: () {
                          Navigator.pop(context);
                          _onTabTapped(3);
                        },
                      ),
                      const Divider(height: 1, indent: 40, endIndent: 8),
                      _buildPopupItem(
                        icon: Icons.edit_note_rounded,
                        color: Colors.orange.shade800,
                        title: 'Buat Catatan Cepat',
                        onTap: () {
                          Navigator.pop(context);
                          _onTabTapped(0);
                        },
                      ),
                      const Divider(height: 1, indent: 40, endIndent: 8),
                      _buildPopupItem(
                        icon: Icons.article_rounded,
                        color: Colors.teal,
                        title: 'Buat Notion Dokumen',
                        onTap: () {
                          Navigator.pop(context);
                          _onTabTapped(0);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          alignment: Alignment.bottomRight,
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _buildPopupItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -3, vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
      ),
      trailing: const Text(
        '👉',
        style: TextStyle(fontSize: 14),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
            tooltip: 'Menu Profil',
            onPressed: () {
              Navigator.push(
                context,
                createTelegramRoute(const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          // Navigasi geser ala Telegram
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),

          // Tombol (+) hanya ada di Home (index 2)
          if (_currentIndex == 2)
            Positioned(
              right: 20,
              bottom: 130,
              child: Material(
                elevation: 6,
                shadowColor: Colors.black38,
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF6D28D9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showCreateDialog,
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Tombol Home Tengah Menonjol
      // Tombol Home Tengah Menonjol
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withAlpha(120),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _onTabTapped(2),
              child: Icon(
                _currentIndex == 2 ? Icons.home_rounded : Icons.home_outlined,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      // Dock Bar Bawah Notched
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        elevation: 12,
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, icon: Icons.description_outlined, activeIcon: Icons.description_rounded, label: 'Notion'),
              _buildNavItem(index: 1, icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories_rounded, label: 'Notebook'),
              const SizedBox(width: 48), // Dudukan lekukan Home
              _buildNavItem(index: 3, icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Jadwal'),
              _buildNavItem(index: 4, icon: Icons.alarm_outlined, activeIcon: Icons.alarm_rounded, label: 'Alarm'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF6D28D9) : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(isSelected ? activeIcon : icon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenPlaceholder extends StatelessWidget {
  const _HomeScreenPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade50),
              child: const Icon(Icons.hub_rounded, size: 56, color: Color(0xFF6D28D9)),
            ),
            const SizedBox(height: 20),
            const Text('AI Productivity Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Kelola catatan cerdas, riset AI, jadwal harian, dan alarm dalam satu aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          Text('Fitur sedang dalam tahap pengembangan', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}