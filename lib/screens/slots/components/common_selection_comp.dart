import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';

class CommonSelectionWid extends StatelessWidget {
  final String title;
  final String selectedName;
  final void Function()? onEdit;
  const CommonSelectionWid({
    super.key,
    required this.title,
    required this.selectedName,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: secondaryTextStyle(size: 12)),
            6.height,
            Marquee(child: Text(selectedName, style: boldTextStyle(size: 14))),
          ],
        ).expand(),
        IconButton(
          onPressed: onEdit,
          icon: const CachedImageWidget(
            url: Assets.iconsIcEditReview,
            height: 20,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }
}
