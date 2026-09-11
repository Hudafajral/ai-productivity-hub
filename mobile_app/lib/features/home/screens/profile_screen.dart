import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../services/auth_service.dart';
import '../../auth/screens/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = 'Workspace Owner';
  String _userTag = '@user_1 • AI Notion Pro';
  String _bio = 'Mengatur produktivitas harian dengan AI Notion & smart schedule alarm.';

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _editNameDialog() {
    final nameController = TextEditingController(text: _displayName);
    final tagController = TextEditingController(text: _userTag);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Identitas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Tampilan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Tag / Username',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
            ),
            onPressed: () {
              setState(() {
                _displayName = nameController.text.trim();
                _userTag = tagController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editBioDialog() {
    final bioController = TextEditingController(text: _bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Tentang Saya',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: bioController,
          maxLines: 3,
          maxLength: 120,
          decoration: const InputDecoration(
            hintText: 'Tulis bio singkat profil...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
            ),
            onPressed: () {
              setState(() => _bio = bioController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _pickAvatarSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ubah Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF6D28D9),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF6D28D9),
                ),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Kamu perlu masuk kembali menggunakan akun Google untuk mengakses data cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F33),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Identitas',
            onPressed: _editNameDialog,
          ),
        ],
      ),
      body: ValueListenableBuilder<GoogleSignInAccount?>(
        valueListenable: AuthService().currentUser,
        builder: (context, user, _) {
          final String displayHeaderName =
              user?.displayName?.isNotEmpty == true ? user!.displayName! : _displayName;
          final String displayTag =
              user != null ? '@${user.email.split('@')[0]} • Google User' : _userTag;
          final String photoUrl = user?.photoUrl ?? '';

          return Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5865F2), Color(0xFF2C2F33)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: -36,
                    child: InkWell(
                      onTap: _pickAvatarSheet,
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF4F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: const Color(0xFF6D28D9),
                              backgroundImage: _avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : (photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl) as ImageProvider
                                      : null),
                              child: _avatarImage == null && photoUrl.isEmpty
                                  ? const Icon(Icons.person, size: 44, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23A55A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF4F4F6),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _editNameDialog,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  displayHeaderName,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit, size: 14, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayTag,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _editBioDialog,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TENTANG SAYA',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_note_rounded,
                                  size: 16,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _bio,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                  child: Column(
                    children: [
                      _buildTelegramSectionHeader('AKUN TERHUBUNG'),
                      _buildTelegramCard([
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(24),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.mail_rounded,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                          title: const Text(
                            'Google Account',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            user?.email ?? 'Belum tersambung',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user != null
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user != null ? 'Tersambung' : 'Hubungkan',
                              style: TextStyle(
                                fontSize: 11,
                                color: user != null
                                    ? Colors.green
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (user == null) {
                              await AuthService().signInWithGoogle();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Akun aktif: ${user.email}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildTelegramSectionHeader('PENGATURAN AKUN'),
                      _buildTelegramCard([
                        _buildTelegramTile(
                          icon: Icons.notifications_none_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Notifikasi & Alarm',
                          subtitle: 'Suara nada jam dan status getar',
                        ),
                        _buildDivider(),
                        _buildTelegramTile(
                          icon: Icons.auto_awesome_outlined,
                          iconColor: const Color(0xFF6D28D9),
                          title: 'Model AI & NotebookLM',
                          subtitle: 'Konfigurasi API Key & Gemini Core',
                        ),
                        _buildDivider(),
                        _buildTelegramTile(
                          icon: Icons.cloud_sync_outlined,
                          iconColor: const Color(0xFF0EA5E9),
                          title: 'Sinkronisasi Cloud',
                          subtitle: 'Terhubung ke PostgreSQL / FastAPI',
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildTelegramSectionHeader('PREFERENSI & KEAMANAN'),
                      _buildTelegramCard([
                        _buildTelegramTile(
                          icon: Icons.palette_outlined,
                          iconColor: const Color(0xFF10B981),
                          title: 'Tema & Tampilan',
                          subtitle: 'Mode terang / gelap otomatis',
                        ),
                        _buildDivider(),
                        _buildTelegramTile(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Privasi & Data',
                          subtitle: 'Cadangan data lokal dan riwayat AI',
                        ),
                      ]),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildTelegramSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  static Widget _buildTelegramCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildTelegramTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(24),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
      onTap: onTap ?? () {},
    );
  }

  static Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }
}