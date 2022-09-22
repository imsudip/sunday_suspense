import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../ui/app_colors.dart';
import '../ui/text_styles.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: CupertinoTextField(
        placeholder: 'Search',
        readOnly: true,
        style: AppTextStyle.bodytext1,
        placeholderStyle: AppTextStyle.bodytext1.copyWith(color: AppColors.textSecondaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Icon(
            Iconsax.search_normal_1,
            color: AppColors.textSecondaryColor,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
