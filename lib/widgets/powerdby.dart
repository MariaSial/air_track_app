import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:flutter/material.dart';

class Powerdby extends StatelessWidget {
  const Powerdby({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Powered By", style: onBoardingstyle.copyWith(fontSize: 16)),
        SizedBox(width: 6),
        Image.asset(
          cfplogo,
          //  width: MediaQuery.sizeOf(context).width * 0.3
        ),
        SizedBox(width: 6),
        Image.asset(
          kpitblogo,
          // width: MediaQuery.sizeOf(context).width * 0.3
        ),
      ],
    );
  }
}
