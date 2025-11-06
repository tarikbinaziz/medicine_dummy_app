// A single-file demo Flutter app (main.dart) implementing the requested UI and features.
// Packages used (add to pubspec.yaml):
//   flutter_riverpod: ^2.3.6
//   flutter_screenutil: ^5.7.0
//   google_fonts: ^5.0.0
// No assets required — uses network images for demo.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------- Models ----------
class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
  });
}

class Comment {
  final String text;
  final DateTime createdAt;

  Comment({required this.text, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}

// ---------- Dummy Data ----------
final List<Product> dummyProducts = [
  Product(
    id: 1,
    title: 'Paracetamol 500mg',
    description: 'Effective for reducing fever and mild pain.',
    image: 'https://picsum.photos/seed/med1/600/600',
    category: 'Pain Relief',
  ),
  Product(
    id: 2,
    title: 'Vitamin C 1000mg',
    description: 'Boosts immunity and overall health.',
    image: 'https://picsum.photos/seed/med2/600/600',
    category: 'Vitamins',
  ),
  Product(
    id: 3,
    title: 'Ibuprofen 200mg',
    description: 'Relieves inflammation and pain.',
    image: 'https://picsum.photos/seed/med3/600/600',
    category: 'Pain Relief',
  ),
  Product(
    id: 4,
    title: 'Multivitamin Capsule',
    description: 'Supports overall well-being and energy.',
    image: 'https://picsum.photos/seed/med4/600/600',
    category: 'Vitamins',
  ),
  Product(
    id: 5,
    title: 'First Aid Cream',
    description: 'Helps in healing minor cuts and burns.',
    image: 'https://picsum.photos/seed/med5/600/600',
    category: 'First Aid',
  ),
  Product(
    id: 6,
    title: 'Calcium Tablets',
    description: 'Strengthens bones and teeth.',
    image: 'https://picsum.photos/seed/med6/600/600',
    category: 'Supplements',
  ),
];

final List<String> dummyBanners = [
  'https://picsum.photos/seed/medbanner1/900/400',
  'https://picsum.photos/seed/medbanner2/900/400',
  'https://picsum.photos/seed/medbanner3/900/400',
];

// ---------- State Management (Riverpod) ----------
// Products provider (simple read-only list for this demo)
final productsProvider = Provider<List<Product>>((ref) => dummyProducts);

// Search filter provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Category filter provider
final categoryFilterProvider = StateProvider<String?>((ref) => null);

// Comments StateNotifier: in-memory storage mapping productId -> List<Comment>
class CommentsNotifier extends StateNotifier<Map<int, List<Comment>>> {
  CommentsNotifier() : super({});

  List<Comment> commentsFor(int productId) =>
      (state[productId] ?? []).reversed.toList(); // latest first

  void addComment(int productId, String text) {
    final list = List<Comment>.from(state[productId] ?? []);
    list.add(Comment(text: text));
    state = {...state, productId: list};
  }

  void clearAll() => state = {};
}

final commentsProvider =
    StateNotifierProvider<CommentsNotifier, Map<int, List<Comment>>>(
      (ref) => CommentsNotifier(),
    );

// ---------- App ----------
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Neon Bazaar',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ).apply(bodyColor: Colors.white),
          ),
          home: const LandingPage(),
        );
      },
    );
  }
}

// ---------- Landing Page ----------
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerController.hasClients) {
        final next = (_bannerController.page ?? 0) + 1;
        _bannerController.animateToPage(
          next.toInt() % dummyBanners.length,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    final filtered = products.where((p) {
      final matchQuery =
          query.isEmpty || p.title.toLowerCase().contains(query.toLowerCase());
      final matchCategory =
          selectedCategory == null || p.category == selectedCategory;
      return matchQuery && matchCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              // Top bar (logo + actions)
              Row(
                children: [
                  _NeonLogo(),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        ref.read(commentsProvider.notifier).clearAll(),
                    icon: const Icon(Icons.clear_all),
                    color: Colors.white70,
                    tooltip: 'Clear all comments (dev)',
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Banner
              SizedBox(
                height: 160.h,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _bannerController,
                      itemCount: dummyBanners.length,
                      itemBuilder: (context, index) {
                        final url = dummyBanners[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 8.h,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.r),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(url, fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.45),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16.w,
                                  bottom: 14.h,
                                  child: Text(
                                    'Hot Picks',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // indicator
                    Positioned(
                      right: 12.w,
                      bottom: 12.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: List.generate(
                            dummyBanners.length,
                            (i) => AnimatedBuilder(
                              animation: _bannerController,
                              builder: (context, child) {
                                final page = (_bannerController.hasClients
                                    ? (_bannerController.page ??
                                          _bannerController.initialPage)
                                    : 0);
                                final active = page.round() == i;
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: Container(
                                    width: active ? 20.w : 8.w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.r),
                                      gradient: active
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF00F5A0),
                                                Color(0xFF00B4FF),
                                              ],
                                            )
                                          : null,
                                      color: active ? null : Colors.white24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Search bar
              _NeonSearchBar(),
              SizedBox(height: 12.h),

              // Category chips
              SizedBox(
                height: 36.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'All',
                      isSelected: selectedCategory == null,
                      onTap: () =>
                          ref.read(categoryFilterProvider.notifier).state =
                              null,
                    ),
                    ...{for (var p in products) p.category}.map(
                      (c) => Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: _CategoryChip(
                          label: c,
                          isSelected: selectedCategory == c,
                          onTap: () =>
                              ref.read(categoryFilterProvider.notifier).state =
                                  c,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Product grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.only(bottom: 20.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 260.h,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _ProductCard(product: product);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Widgets ----------
class _NeonLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00F5A0), Color(0xFF00B4FF)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.25),
                blurRadius: 12.r,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.storefront_outlined,
            color: Colors.black87,
            size: 26.w,
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Neon',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            Text(
              'Bazaar',
              style: TextStyle(fontSize: 12.sp, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class _NeonSearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white70),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
            child: Icon(Icons.close, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00F5A0), Color(0xFF00B4FF)],
                )
              : null,
          color: isSelected ? null : Colors.white10,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.03),
              Colors.white.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: Image.network(
                  product.image,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Product Details Page ----------
class ProductDetailsPage extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailsPage({required this.product, super.key});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _commentController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsMap = ref.watch(commentsProvider);
    final comments = commentsMap[widget.product.id]?.reversed.toList() ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product_image_${widget.product.id}',
                  child: Image.network(
                    widget.product.image,
                    height: 340.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 340.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 18.w,
                  bottom: 18.h,
                  child: Text(
                    widget.product.title,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          widget.product.category,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 6.w),
                      Text(
                        '4.8',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Comments area
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Comment input
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.white10,
                          ),
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          final text = _commentController.text.trim();
                          if (text.isNotEmpty) {
                            ref
                                .read(commentsProvider.notifier)
                                .addComment(widget.product.id, text);
                            _commentController.clear();
                            // subtle feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment added')),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F5A0), Color(0xFF00B4FF)],
                            ),
                          ),
                          child: Icon(Icons.send, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Comments list
                  AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeController.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: comments.isEmpty
                          ? [
                              SizedBox(height: 40.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment_bank_outlined,
                                    color: Colors.white24,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'No comments yet — be the first!',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ]
                          : comments
                                .map((c) => _CommentTile(comment: c))
                                .toList(),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00F5A0), Color(0xFF00B4FF)],
              ),
            ),
            child: Center(
              child: Text(
                comment.createdAt.hour.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Guest',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '• ${_formatTimeAgo(comment.createdAt)}',
                      style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(comment.text, style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ---------- End of file ----------
