import 'package:flutter/material.dart';

class TitleBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double topPadding;
  final VoidCallback onSearch;

  const TitleBarDelegate(this.title, this.topPadding, [this.onSearch]);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline,
      child: Stack(
        children: <Widget>[
          Container(
            color: Theme.of(context).canvasColor,
            height: (maxExtent - shrinkOffset).clamp(minExtent, maxExtent).toDouble(),
          ),
          if (onSearch != null)
            Positioned(
              top: 4 + topPadding,
              right: 4,
              child: IconButton(
                onPressed: () {},//=> Navigator.pop(context),
                icon: const Icon(Icons.search),
              ),
            ),
          Positioned(
            top: topPadding,
            left: 20,
            bottom: 0,
            child: Align(
              alignment: Alignment(0, 40 / (40 + kToolbarHeight) * ((60 - shrinkOffset.clamp(0.0, 60.0)) / 60)),
              child: Text(title),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight + 60 + topPadding;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}