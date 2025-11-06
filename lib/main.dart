// main.dart
// Light-mode pharmacy style product app (single file).
// Packages required:
//  flutter_riverpod, flutter_screenutil, google_fonts

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
  final double price;
  final double discountPrice;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    this.price = 0.0,
    this.discountPrice = 0.0,
  });
}

class Comment {
  final String text;
  final DateTime createdAt;

  Comment({required this.text, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}

// ---------- Dummy Data (Medicine) ----------
final List<Product> dummyProducts = [
  Product(
    id: 1,
    title: 'Paracetamol 500mg',
    description: 'Effective for reducing fever and mild pain.',
    image: 'assets/png/istockphoto-156292188-612x612.jpg',
    category: 'Pain Relief',
    price: 5.99,
    discountPrice: 4.99,
  ),
  Product(
    id: 2,
    title: 'Vitamin C 1000mg',
    description: 'Boosts immunity and overall health.',
    image: 'assets/png/premium_photo-1668487826871-2f2cac23ad56.jpeg',
    category: 'Vitamins',
    price: 7.99,
    discountPrice: 6.99,
  ),
  Product(
    id: 3,
    title: 'Ibuprofen 200mg',
    description: 'Relieves inflammation and moderate pain.',
    image: 'assets/png/SCR-20251106-pjxu.png',
    category: 'Pain Relief',
    price: 9.99,
    discountPrice: 8.99,
  ),
  Product(
    id: 4,
    title: 'Multivitamin Capsule',
    description: 'Supports overall well-being and energy.',
    image: 'assets/png/SCR-20251106-pkba.png',
    category: 'Vitamins',
    price: 12.99,
    discountPrice: 10.99,
  ),
  Product(
    id: 5,
    title: 'First Aid Cream',
    description: 'Helps in healing minor cuts and burns.',
    image: 'assets/png/SCR-20251106-pksj.png',
    category: 'First Aid',
    price: 14.99,
    discountPrice: 12.99,
  ),
  Product(
    id: 6,
    title: 'Calcium Tablets',
    description: 'Strengthens bones and teeth.',
    image: 'assets/png/SCR-20251106-pkua.png',
    category: 'Supplements',
    price: 11.99,
    discountPrice: 9.99,
  ),
];

final List<String> dummyBanners = [
  "assets/png/SCR-20251106-pkua.png",
  "assets/png/SCR-20251106-pjxu.png",
  "assets/png/SCR-20251106-pkba.png",
  "assets/png/SCR-20251106-pksj.png",
];

// ---------- Riverpod providers ----------
final productsProvider = Provider<List<Product>>((ref) => dummyProducts);
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String?>((ref) => null);

class CommentsNotifier extends StateNotifier<Map<int, List<Comment>>> {
  CommentsNotifier() : super({});

  List<Comment> commentsFor(int productId) =>
      (state[productId] ?? []).reversed.toList();

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

  static const Color primaryBlue = Color(0xFF2F80ED);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        final base = ThemeData.light();
        final theme = base.copyWith(
          primaryColor: primaryBlue,
          colorScheme: base.colorScheme.copyWith(primary: primaryBlue),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            centerTitle: false,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            base.textTheme,
          ).apply(bodyColor: Colors.black87),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 6,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pharma Shop',
          theme: theme,
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
          duration: const Duration(milliseconds: 600),
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pharma Shop',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Developed by Tarik Bin Aziz, 01641586586',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        actions: [],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner slider
              SizedBox(
                height: 150.h,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: dummyBanners.length,
                  itemBuilder: (context, index) {
                    final url = dummyBanners[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Image.asset(url, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 14.h),

              // Search bar
              _SearchRow(),

              SizedBox(height: 12.h),

              // Category chips
              SizedBox(
                height: 40.h,
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

              // Product grid (2 columns)
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
class _SearchRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Search medicine, e.g., Paracetamol',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        ElevatedButton(
          onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
          child: const Text('Reset'),
        ),
      ],
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
    final Color selectedColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.14),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: Image.asset(
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    product.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// ✅ Price Row
                  Row(
                    children: [
                      Text(
                        "৳${product.price}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "৳${product.discountPrice}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black45,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
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

// ---------- Product Details ----------
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
      duration: const Duration(milliseconds: 500),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_image_${widget.product.id}',
              child: Image.asset(
                widget.product.image,
                height: 300.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          widget.product.category,
                          style: theme.textTheme.bodySmall,
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
                  SizedBox(height: 14.h),

                  // Add this just below product title (inside Padding widget)
                  Row(
                    children: [
                      Text(
                        "৳${widget.product.price}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 19.sp,
                          color: const Color(0xFF2F80ED), // main accent color
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "৳${widget.product.discountPrice}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black38,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // ✅ Discount badge
                      if (widget.product.discountPrice > widget.product.price)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withOpacity(.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "-${(((widget.product.discountPrice - widget.product.price) / widget.product.discountPrice) * 100).round()}%",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2F80ED),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  SizedBox(height: 14.h),
                  Text(
                    'Product Details',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Comments header
                  Text(
                    'Comments',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Comment input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: () {
                          final text = _commentController.text.trim();
                          if (text.isNotEmpty) {
                            ref
                                .read(commentsProvider.notifier)
                                .addComment(widget.product.id, text);
                            _commentController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment added')),
                            );
                          }
                        },
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Comments list
                  AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) =>
                        Opacity(opacity: _fadeController.value, child: child),
                    child: Column(
                      children: comments.isEmpty
                          ? [
                              SizedBox(height: 30.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment_bank_outlined,
                                    color: Colors.black26,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'No comments yet — be the first!',
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                ],
                              ),
                            ]
                          : comments
                                .map((c) => _CommentTile(comment: c))
                                .toList(),
                    ),
                  ),

                  SizedBox(height: 30.h),
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
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.blue[50],
            child: Text(
              comment.createdAt.hour.toString().padLeft(2, '0'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(width: 12.w),
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
                      style: TextStyle(color: Colors.black45, fontSize: 12.sp),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(comment.text, style: TextStyle(color: Colors.black87)),
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
