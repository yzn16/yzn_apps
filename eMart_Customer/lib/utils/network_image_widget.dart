import 'package:cached_network_image/cached_network_image.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/theme/responsive.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.fitWidth,
      height: height ?? Responsive.height(8, context),
      width: width ?? Responsive.width(15, context),
      color: color,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Image.network(
            placeholderImage,
            fit: fit ?? BoxFit.fitWidth,
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
          ),
    );
  }
}
