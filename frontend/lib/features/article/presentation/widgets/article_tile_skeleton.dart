import 'package:flutter/material.dart';

class ArticleTileSkeleton extends StatelessWidget {
  const ArticleTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
          start: 14, end: 14, bottom: 7, top: 7),
      height: MediaQuery.of(context).size.width / 2.2,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.black.withAlpha(50),
                ),
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.black.withAlpha(50),
                ),
                Container(
                  height: 15,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Colors.black.withAlpha(50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}