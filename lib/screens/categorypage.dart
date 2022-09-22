import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'show_all_page.dart';
import '../services/database_service.dart';
import '../ui/app_colors.dart';
import '../ui/text_styles.dart';

class CategoryPageScreen extends StatelessWidget {
  const CategoryPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Categories",
                  style: AppTextStyle.headline2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    CategoryCard2(
                      title: "🔪🩸 Crime",
                      keyword: "crime",
                    ),
                    CategoryCard2(
                      title: "👻💀 Horror",
                      keyword: "horror",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard2(
                      title: "🛩️🏖️ Adventure",
                      keyword: "adventure",
                    ),
                    CategoryCard2(
                      title: "😱🧟 Thriller",
                      keyword: "thriller",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Fictional Characters",
                  style: AppTextStyle.headline2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    CategoryCard(
                      title: "🎩 Sherlock Holmes",
                      keyword: "sherlock",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "🚬 Feluda",
                      keyword: "feluda",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "👓 Byomkesh Bakshi",
                      keyword: "byomkesh",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "👴 Professor Shonku",
                      keyword: "shonku",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "Taranath Tantrik",
                      keyword: "taranath",
                    ),
                    CategoryCard(
                      title: "Tarini Khuro",
                      keyword: "tarini",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Reowned Authors",
                  style: AppTextStyle.headline2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    CategoryCard(
                      title: "Sir Arthur Conan Doyle",
                      keyword: "arthur conan doyle",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "Satyajit Ray",
                      keyword: "satyajit ray",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "Shorodindu Bandopadhyay",
                      keyword: "shorodindu bandopadhyay",
                    ),
                  ],
                ),
                Row(
                  children: const [
                    CategoryCard(
                      title: "Taradas Bandopadhyay",
                      keyword: "taradas bandopadhyay",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.title,
    required this.keyword,
  }) : super(key: key);
  final String title, keyword;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Bounceable(
        onTap: () {
          Get.to(() => ShowAllPage(
                title: title,
                future: (page) {
                  return DatabaseService.getSongsUsingTag(keyword, page: page);
                },
              ));
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(4),
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyle.subHeading.copyWith(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard2 extends StatelessWidget {
  const CategoryCard2({
    Key? key,
    required this.title,
    required this.keyword,
  }) : super(key: key);
  final String title, keyword;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Bounceable(
        onTap: () {
          Get.to(() => ShowAllPage(
                title: title,
                future: (page) {
                  return DatabaseService.getSongByCategory(keyword, page: page);
                },
              ));
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(4),
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyle.subHeading.copyWith(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
