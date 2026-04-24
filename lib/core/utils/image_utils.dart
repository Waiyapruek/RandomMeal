import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Optimizes image URLs with sizing & quality parameters for faster loading
/// Reduces bandwidth by requesting only the needed resolution
String optimizeImageUrl(String? imageUrl, {int width = 300, int height = 300}) {
  if (imageUrl == null || imageUrl.isEmpty) return '';
  
  // Unsplash optimization - request smaller size & lower quality for faster loading
  if (imageUrl.contains('unsplash.com')) {
    if (imageUrl.contains('?')) {
      // Already has parameters, just ensure w and h are set
      if (!imageUrl.contains('w=')) {
        imageUrl += '&w=$width';
      }
      if (!imageUrl.contains('h=')) {
        imageUrl += '&h=$height';
      }
      // Ensure quality compression for smaller file size
      if (!imageUrl.contains('q=')) {
        imageUrl += '&q=70';
      }
    } else {
      // No parameters yet, add them with compression
      // q=70 gives good quality while reducing size significantly
      imageUrl += '?w=$width&h=$height&fit=crop&q=70&auto=format';
    }
  }
  
  return imageUrl;
}

/// Widget for optimized image loading with fade animation
class OptimizedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final int width;
  final int height;
  final Duration fadeDuration;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?) loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?) errorBuilder;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width = 400,
    this.height = 400,
    this.fadeDuration = const Duration(milliseconds: 300),
    required this.loadingBuilder,
    required this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = optimizeImageUrl(imageUrl, width: width, height: height);

    if (optimizedUrl.isEmpty) {
      return errorBuilder(context, Exception('No image URL'), StackTrace.empty);
    }

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      fit: fit,
      // Show loading widget while downloading
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: loadingBuilder(context, const SizedBox(), null),
        ),
      ),
      errorWidget: (context, url, error) => 
          errorBuilder(context, error, StackTrace.empty),
      filterQuality: FilterQuality.medium,

      // Smooth fade animation
      fadeInDuration: fadeDuration,
      fadeOutDuration: fadeDuration,
      
      // Use cache key to prevent duplicate downloads
      cacheKey: '$optimizedUrl?w=$width&h=$height',
      
      // Progressive image loading (load low quality first if available)
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
    );
  }
}

/// Initialize aggressive image caching for fast loading
void initializeImageCache() {
  // Increase image cache to 50MB (default is 10MB)
  imageCache.maximumSizeBytes = 50 * 1024 * 1024;
  // Keep up to 100 images in memory
  imageCache.maximumSize = 100;
}
