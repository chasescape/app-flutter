import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'soft_ui.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const PostCard({
    super.key,
    required this.post,
    this.height = 240,
    this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return NeniaPhotoCard(
      onTap: onTap,
      height: height,
      label: post.tags.isNotEmpty ? '#${post.tags.first}' : 'Story',
      title: post.title,
      subtitle: '${post.likes} likes',
      image: Stack(
        fit: StackFit.expand,
        children: [
          NeniaAdaptiveImage(path: post.imageUrl),
          if (onLike != null)
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: post.isLiked ? Colors.pinkAccent : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
