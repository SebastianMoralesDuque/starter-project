import 'package:flutter/material.dart';

class ArticleDetailSkeleton extends StatelessWidget {
  const ArticleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.black.withAlpha(50),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Colors.black.withAlpha(50),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width / 3,
                  color: Colors.black.withAlpha(50),
                ),
              ],
            ),
          ),
          Container(
            width: double.maxFinite,
            height: 250,
            margin: const EdgeInsets.only(top: 14),
            color: Colors.grey.shade300,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                6,
                (index) => Container(
                  height: 16,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.black.withAlpha(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}