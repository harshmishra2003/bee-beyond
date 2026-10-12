import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(allCoursesProvider);

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
              // Categories Filter
              if (categories.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                              _selectedSubCategory = null; // Reset subcategory when category changes
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                
              // Subcategories Filter
              if (subCategories.isNotEmpty)
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: subCategories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
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

              // Course List
              Expanded(
                child: filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text(
                              'No courses found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different category\nor removing filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = null;
                                  _selectedSubCategory = null;
                                });
                              },
                              child: const Text('View All Courses', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
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
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected 
              ? (isSubCategory ? AppColors.secondary : AppColors.primary)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (isSubCategory ? AppColors.secondary : AppColors.primary)
                : AppColors.borderSubtle,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isSubCategory ? AppColors.secondary : AppColors.primary).withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: isSubCategory ? 13 : 14,
          ),
        ),
      ),
    );
  }
}
