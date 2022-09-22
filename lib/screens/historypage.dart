import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sunday_suspense/services/database_service.dart';
import 'package:sunday_suspense/ui/text_styles.dart';
import 'package:sunday_suspense/widgets/song_viewers.dart';

import '../ui/app_colors.dart';

class HistoryPageScreen extends StatefulWidget {
  const HistoryPageScreen({super.key});

  @override
  State<HistoryPageScreen> createState() => _HistoryPageScreenState();
}

class _HistoryPageScreenState extends State<HistoryPageScreen> {
  List<dynamic> history = [];

  final box = GetStorage('HistoryBox');

  @override
  void initState() {
    box.listen(() {
      if (mounted) {
        setState(() {});
        if (history.length != box.getKeys().length) {
          DatabaseService.getSongFromListt(box.getKeys().map<String>((e) => e.toString()).toList()).then((value) {
            setState(() {
              history = value;
            });
          });
        }
      }
    });
    DatabaseService.getSongFromListt(box.getKeys().map<String>((e) => e.toString()).toList()).then((value) {
      setState(() {
        history = value;
      });
    });
    // print(box.getKeys());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "History",
                style: AppTextStyle.headline2,
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) {
                  return MinimalVerticalListCard(
                    songs: history,
                    index: index,
                    history: Duration(
                      seconds: box.read(history[index]['video_id']),
                    ),
                  );
                },
                itemCount: history.length,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
