import 'package:flutter/material.dart';
import 'package:adoptandlove/widgets/progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GetPetNetworkImage extends StatelessWidget {
  final String url;
  final String fallbackAssetImage;
  final bool useDiskCache;
  final bool showLoadingIndicator;
  final Color color;

  const GetPetNetworkImage({
    Key key,
    @required this.url,
    this.color,
    this.fallbackAssetImage,
    this.useDiskCache: false,
    this.showLoadingIndicator = true,
  })  : assert(url != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Function image = (ImageProvider imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.transparent, BlendMode.colorBurn)),
          ),
        );

    return CachedNetworkImage(
        imageUrl: url,
        cacheKey: url,
        httpHeaders: {
          'accept': 'image/webp,image/*;q=0.85',
          'sec-fetch-dest': 'image',
        },
        placeholder: (context, url) => Icon(
              Icons.error_outline,
              color: this.color,
            ),
        errorWidget: (context, url, error) =>
            image(AssetImage(this.fallbackAssetImage)),
        imageBuilder: (context, imageProvider) => image(imageProvider));
    // return AdvancedNetworkImage(
    //     url,
    //     useDiskCache: this.useDiskCache,
    //     fallbackAssetImage: this.fallbackAssetImage,
    //     header: {
    //       'accept': 'image/webp,image/*;q=0.85',
    //       'sec-fetch-dest': 'image',
    //     },
    //   ),
    //   printError: true,
    //   fit: BoxFit.cover,
    //   placeholder: Icon(
    //     Icons.error_outline,
    //     color: this.color,
    //   ),
    //   enableRefresh: true,
    //   loadingWidget: this.showLoadingIndicator
    //       ? Center(
    //           child: AppProgressIndicator(
    //             color: this.color,
    //           ),
    //         )
    //       : SizedBox()
  }
}
