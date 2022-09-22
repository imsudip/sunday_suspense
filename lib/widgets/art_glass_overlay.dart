import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../ui/app_colors.dart';

import '../page_manager.dart';
import '../services/service_locator.dart';

class ArtGlass extends StatelessWidget {
  const ArtGlass(
      {super.key, required this.child, this.intensity = 0.0, this.backgroundColor = AppColors.backgroundColor});
  final Widget child;
  final double intensity;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongImageNotifier,
      builder: (_, art, __) {
        if (art == "") {
          return Container(
            child: child,
          );
        } else {
          return Stack(
            children: [
              Container(
                color: backgroundColor,
              ),
              Positioned(
                top: -25,
                bottom: max(MediaQuery.of(context).size.height * 0.5, 60),
                child: CachedNetworkImage(
                  imageUrl: art,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: backgroundColor.withOpacity(intensity),
              ),
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: child),
            ],
          );
        }
      },
    );
  }
}

class ArtGlassSmall extends StatelessWidget {
  const ArtGlassSmall(
      {super.key, required this.child, this.intensity = 0.0, this.backgroundColor = AppColors.backgroundColor});
  final Widget child;
  final double intensity;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongImageNotifier,
      builder: (_, art, __) {
        if (art == "") {
          return SizedBox(
            height: 62,
            child: child,
          );
        } else {
          return SizedBox(
            height: 130,
            child: Stack(
              children: [
                Container(
                  color: backgroundColor,
                ),
                Positioned(
                  bottom: -25,
                  top: 100,
                  child: CachedNetworkImage(
                    imageUrl: art,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: backgroundColor.withOpacity(intensity),
                ),
                BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: child),
              ],
            ),
          );
        }
      },
    );
  }
}
