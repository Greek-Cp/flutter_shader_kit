import 'package:flutter/material.dart';
import 'package:flutter_shader_kit/widgets/curl_card.dart';

/// A beautiful note-taking app demo showcasing CurlCard usage
/// with realistic paper-like design
class NoteAppDemo extends StatefulWidget {
  const NoteAppDemo({super.key});

  @override
  State<NoteAppDemo> createState() => _NoteAppDemoState();
}

class _NoteNote {
  final String title;
  final String date;
  final List<String> content;
  final Color accentColor;
  final IconData icon;

  const _NoteNote({
    required this.title,
    required this.date,
    required this.content,
    required this.accentColor,
    required this.icon,
  });
}

class _NoteAppDemoState extends State<NoteAppDemo> {
  int _currentNoteIndex = 0;

  final List<_NoteNote> _notes = const [
    _NoteNote(
      title: 'Rencana Liburan Akhir Tahun',
      date: '15 Oktober 2025',
      content: [
        '📍 Destinasi: Bali',
        '',
        '• Hari 1-2: Ubud (Tegalalang, Monkey Forest)',
        '• Hari 3-4: Seminyak Beach & Tanah Lot',
        '• Hari 5: Nusa Penida (snorkeling)',
        '',
        'Budget: ~Rp 8.000.000',
        'Hotel: Villa di Seminyak',
        '',
        'Jangan lupa:',
        '✓ Booking hotel 2 minggu sebelumnya',
        '✓ Siapkan sunscreen & kamera underwater',
        '✓ Cek promo tiket pesawat',
      ],
      accentColor: Color(0xFF3498DB),
      icon: Icons.flight_takeoff,
    ),
    _NoteNote(
      title: 'Ide Project Aplikasi',
      date: '18 Oktober 2025',
      content: [
        '💡 Aplikasi Personal Finance Tracker',
        '',
        'Fitur utama:',
        '1. Dashboard expense dengan chart',
        '2. Kategori custom (makanan, transport, dll)',
        '3. Reminder tagihan bulanan',
        '4. Export data ke CSV/PDF',
        '5. Multi-currency support',
        '',
        'Tech stack:',
        '• Flutter + Dart',
        '• Firebase untuk backend',
        '• Chart library: fl_chart',
        '• Local storage: Hive',
        '',
        'Timeline: 2-3 bulan development',
      ],
      accentColor: Color(0xFF9B59B6),
      icon: Icons.lightbulb_outline,
    ),
    _NoteNote(
      title: 'Resep Nasi Goreng Spesial',
      date: '12 Oktober 2025',
      content: [
        '🍳 Bahan-bahan:',
        '• 2 piring nasi putih (dingin)',
        '• 3 siung bawang putih',
        '• 5 siung bawang merah',
        '• 2 butir telur',
        '• 100gr ayam fillet (potong dadu)',
        '• Kecap manis, saus tiram',
        '• Garam, merica, kaldu bubuk',
        '',
        '👨‍🍳 Cara membuat:',
        '1. Tumis bumbu halus sampai harum',
        '2. Masukkan ayam, masak hingga matang',
        '3. Tambahkan telur, orak-arik',
        '4. Masukkan nasi, aduk rata',
        '5. Beri kecap & bumbu, test rasa',
        '',
        'Sajikan dengan kerupuk & acar! 😋',
      ],
      accentColor: Color(0xFFE67E22),
      icon: Icons.restaurant,
    ),
    _NoteNote(
      title: 'Daftar Buku untuk Dibaca',
      date: '10 Oktober 2025',
      content: [
        '📚 Reading List 2025:',
        '',
        'Fiction:',
        '1. "Atomic Habits" - James Clear',
        '2. "The Psychology of Money" - Morgan Housel',
        '3. "Sapiens" - Yuval Noah Harari',
        '',
        'Programming:',
        '1. "Clean Code" - Robert C. Martin',
        '2. "Flutter Complete Reference" - Alberto Miola',
        '3. "Designing Data-Intensive Applications"',
        '',
        'Target: 1 buku per bulan',
        '',
        'Catatan: Beli di toko buku minggu depan',
        'atau cek versi digital di e-book store',
      ],
      accentColor: Color(0xFF27AE60),
      icon: Icons.menu_book,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.9;
    final cardHeight = size.height * 0.75;
    final currentNote = _notes[_currentNoteIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // Warm paper background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B7355),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'My Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentNoteIndex + 1} / ${_notes.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CurlCard(
              width: cardWidth,
              height: cardHeight,
              borderRadius: 8,
              content: _buildNotePage(currentNote),
              actionLayer: _buildActionLayer(currentNote),
              onCurlComplete: (amount) {
                if (amount > 0.7) {
                  // Pindah ke note selanjutnya
                  setState(() {
                    final nextNote = _currentNoteIndex < _notes.length - 1
                        ? _notes[_currentNoteIndex + 1]
                        : _notes[0];

                    if (_currentNoteIndex < _notes.length - 1) {
                      _currentNoteIndex++;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(nextNote.icon, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Membuka: ${nextNote.title}'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF8B7355),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else {
                      _currentNoteIndex = 0; // Kembali ke awal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(nextNote.icon, color: Colors.white),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Kembali ke note pertama'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF8B7355),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  });
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF8B7355),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Tulis Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotePage(_NoteNote note) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF9), // Paper white
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Lined paper effect
          Positioned.fill(
            child: CustomPaint(
              painter: _LinedPaperPainter(),
            ),
          ),
          // Red margin line
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 50,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFFE74C3C), width: 2),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(
              left: 65,
              right: 24,
              top: 30,
              bottom: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: note.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        note.icon,
                        color: note.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                          fontFamily: 'serif',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      note.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Note content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: note.content.map((line) {
                        if (line.isEmpty) {
                          return const SizedBox(height: 12);
                        }
                        // Check if line starts with bullet or number
                        final isBullet = line.startsWith('•') ||
                            line.startsWith('✓') ||
                            line.startsWith('📍') ||
                            line.startsWith('💡') ||
                            line.startsWith('🍳') ||
                            line.startsWith('👨‍🍳') ||
                            line.startsWith('📚');
                        final isNumbered = RegExp(r'^\d+\.').hasMatch(line);

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 8,
                            left: (isBullet || isNumbered) ? 0 : 0,
                          ),
                          child: Text(
                            line,
                            style: TextStyle(
                              fontSize: line.contains('📍') ||
                                      line.contains('💡') ||
                                      line.contains('🍳') ||
                                      line.contains('📚')
                                  ? 18
                                  : 15,
                              fontWeight: line.contains('📍') ||
                                      line.contains('💡') ||
                                      line.contains('🍳') ||
                                      line.contains('📚')
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Swipe indicator
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_back,
                        color: Color(0xFF95A5A6),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Geser ke kiri untuk note berikutnya',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF95A5A6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLayer(_NoteNote note) {
    final nextIndex =
        _currentNoteIndex < _notes.length - 1 ? _currentNoteIndex + 1 : 0;
    final nextNote = _notes[nextIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF8B7355), // Brown theme
            const Color(0xFF6D5A47), // Darker brown
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    nextNote.icon,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nextIndex == 0 ? 'Kembali ke Awal' : 'Note Selanjutnya',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 150,
                  child: Text(
                    nextNote.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to create lined paper effect
class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E4D9).withOpacity(0.6)
      ..strokeWidth = 1;

    // Draw horizontal lines
    const lineSpacing = 32.0;
    const startY = 60.0;

    for (double y = startY; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(50, y),
        Offset(size.width - 24, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
