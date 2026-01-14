import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// ⚠️ تأكد أن هذه الملفات موجودة في هذه المسارات بالضبط:
import '../models/challenge_model.dart'; // يجب أن يكون في lib/models/
import '../widgets/challenge_card.dart'; // يجب أن يكون في lib/widgets/
import '../providers/theme_provider.dart'; // يجب أن يكون في lib/providers/
import 'add_challenge_screen.dart'; // يجب أن يكون بجانب هذا الملف في lib/screens/

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // تيار البيانات المباشر من قاعدة البيانات
  final Stream<QuerySnapshot> _challengesStream = FirebaseFirestore.instance
      .collection('challenges')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Challenges'),
        actions: [
          // زر تغيير الثيم
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. شريط البحث ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search challenges...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
              onChanged: (val) {
                setState(() {}); // تحديث البحث عند الكتابة
              },
            ),

            const SizedBox(height: 16),

            // --- 2. الفلاتر ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Easy', 'Medium', 'Hard'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // --- 3. القائمة (StreamBuilder) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تأكد أن SectionHeader موجود أو احذفه إذا لم تنشئه
                  // SectionHeader(title: 'Available Challenges'),
                  const Text(
                    'Available Challenges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _challengesStream,
                      builder: (context, snapshot) {
                        // حالات الخطأ والانتظار
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // فلترة البيانات محلياً
                        final challenges = snapshot.data!.docs
                            .map((doc) {
                              return ChallengeModel.fromMap(
                                doc.data() as Map<String, dynamic>,
                              );
                            })
                            .where((challenge) {
                              final filterMatch =
                                  _selectedFilter == 'All' ||
                                  challenge.difficulty.name.toLowerCase() ==
                                      _selectedFilter.toLowerCase();
                              final searchMatch =
                                  _searchController.text.isEmpty ||
                                  challenge.title.toLowerCase().contains(
                                    _searchController.text.toLowerCase(),
                                  );
                              return filterMatch && searchMatch;
                            })
                            .toList();

                        if (challenges.isEmpty) {
                          return const Center(
                            child: Text('No challenges found.'),
                          );
                        }

                        // عرض القائمة
                        return ListView.builder(
                          itemCount: challenges.length,
                          itemBuilder: (context, index) {
                            return ChallengeCard(
                              challenge: challenges[index],

                              // عند الضغط: فتح شاشة التعديل
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddChallengeScreen(
                                      challengeToEdit: challenges[index],
                                    ),
                                  ),
                                );
                              },

                              // عند الحذف
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Challenge?'),
                                    content: const Text(
                                      'Are you sure you want to delete this?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('challenges')
                                      .doc(challenges[index].id)
                                      .delete();
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // زر الإضافة العائم
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChallengeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
