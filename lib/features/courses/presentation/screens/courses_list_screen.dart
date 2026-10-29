import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/course_card.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../routing/route_paths.dart';
import '../providers/course_provider.dart';
import '../../domain/entities/course_entity.dart';

class CoursesListScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const CoursesListScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends ConsumerState<CoursesListScreen> {
  String? _selectedCategory;
  String? _selectedSubCategory;

  bool _isLottieActive = true;
  DateTime? _dataResponseTime;
  Timer? _postResponseTimer;

  @override
  void dispose() {
    _postResponseTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(covariant CoursesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory && widget.initialCategory != null) {
      setState(() {
        _selectedCategory = widget.initialCategory;
        _selectedSubCategory = null;
      });
    }
  }

  List<String> _extractCategories(List<CourseEntity> courses) {
    final Set<String> cats = {};
    for (var course in courses) {
      if (course.category.isNotEmpty) cats.add(course.category);
    }
    return cats.toList()..sort();
  }

  List<String> _extractSubCategories(List<CourseEntity> courses, String category) {
    final Set<String> subCats = {};
    for (var course in courses) {
      if (course.category == category && course.subCategory != null && course.subCategory!.isNotEmpty) {
        subCats.add(course.subCategory!);
      }
    }
    return subCats.toList()..sort();
  }

  List<CourseEntity> _filterCourses(List<CourseEntity> courses) {
    return courses.where((course) {
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (course.category != _selectedCategory) return false;
        if (_selectedSubCategory != null && _selectedSubCategory!.isNotEmpty) {
          if (course.subCategory != _selectedSubCategory) return false;
        }
      }
      return true;
    }).toList();
  }

  Widget _buildCoursesLottieLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFAF9FE),
            Color(0xFFFFFFFF),
            Color(0xFFF2F0FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Lottie.asset(
          AssetPaths.lottieLoading,
          width: 260,
          height: 260,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.school_rounded,
            size: 80,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(allCoursesProvider);

    coursesAsync.whenData((_) {
      if (_dataResponseTime == null) {
        _dataResponseTime = DateTime.now();
        _postResponseTimer?.cancel();
        _postResponseTimer = Timer(const Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() {
              _isLottieActive = false;
            });
          }
        });
      }
    });

    if (coursesAsync.hasError && _dataResponseTime == null) {
      _dataResponseTime = DateTime.now();
      _postResponseTimer?.cancel();
      _postResponseTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _isLottieActive = false;
          });
        }
      });
    }

    if (_isLottieActive || coursesAsync.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9FE),
        body: _buildCoursesLottieLoadingOverlay(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Certified Online Courses',
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push(RoutePaths.joinedCourses),
            tooltip: 'Joined Courses',
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (allCourses) {
          final categories = _extractCategories(allCourses);
          final filteredCourses = _filterCourses(allCourses);
          
          List<String> subCategories = [];
          if (_selectedCategory != null) {
            subCategories = _extractSubCategories(allCourses, _selectedCategory!);
          }

          return Column(
            children: [
              // Categories Filter Bar
              if (categories.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildFilterChip(
                            label: 'All Courses',
                            isSelected: _selectedCategory == null,
                            onTap: () {
                              setState(() {
                                _selectedCategory = null;
                                _selectedSubCategory = null;
                              });
                            },
                          );
                        }
                        final category = categories[index - 1];
                        return _buildFilterChip(
                          label: category,
                          isSelected: _selectedCategory == category,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _selectedSubCategory = null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                
              // Subcategories Filter Bar
              if (subCategories.isNotEmpty)
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: subCategories.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildFilterChip(
                            label: 'All $_selectedCategory',
                            isSelected: _selectedSubCategory == null,
                            isSubCategory: true,
                            onTap: () {
                              setState(() {
                                _selectedSubCategory = null;
                              });
                            },
                          );
                        }
                        final subCategory = subCategories[index - 1];
                        return _buildFilterChip(
                          label: subCategory,
                          isSelected: _selectedSubCategory == subCategory,
                          isSubCategory: true,
                          onTap: () {
                            setState(() {
                              _selectedSubCategory = subCategory;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

              // Course List or Empty Placeholder
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(allCoursesProvider);
                  },
                  child: filteredCourses.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: filteredCourses.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];
                            return SizedBox(
                              width: double.infinity,
                              child: CourseCard(
                                title: course.title,
                                category: course.subCategory ?? course.category,
                                imageUrl: course.imageUrl,
                                price: course.price,
                                duration: course.duration,
                                rating: course.rating,
                                createdAt: course.createdAt,
                                isNew: course.isNewCourse,
                                onTap: () => context.push('${RoutePaths.courseDetail}?id=${course.id}'),
                                onJoinGroup: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Joined study group!')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  // SLEEK COMPACT FILTER CHIP
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isSubCategory = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSubCategory ? 12 : 14,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected 
              ? (isSubCategory ? AppColors.secondary : AppColors.primary)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected 
                ? (isSubCategory ? AppColors.secondary : AppColors.primary)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isSubCategory ? AppColors.secondary : AppColors.primary).withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: isSubCategory ? 12 : 13,
          ),
        ),
      ),
    );
  }

  // STUNNING ELEGANT EMPTY STATE PLACEHOLDER
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Emblem Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF2F0FC),
                border: Border.all(color: AppColors.primary.withAlpha(60), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A4B489B),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Courses Found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No courses match your selected category filter.\nTry picking another category or reset filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            // Compact Elegant Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: AppColors.primaryGradient,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x334B489B),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedSubCategory = null;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Reset & View All Courses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
