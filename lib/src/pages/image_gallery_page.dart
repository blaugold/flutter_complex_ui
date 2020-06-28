import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../widgets/widgets.dart';

class ImageGalleryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: [
          const _ImageThumbnail(
            image: AssetImage('images/1.jpg'),
          ),
          Container(width: 20),
          const _ImageThumbnail(
            image: AssetImage('images/2.jpg'),
          ),
          Container(width: 20),
          const _ImageThumbnail(
            image: AssetImage('images/3.jpg'),
          )
        ].toRow(mainAxisSize: MainAxisSize.min).padding(horizontal: 20),
      ).fractionallySizedBox(widthFactor: 1),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    @required this.image,
  });

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CircularClipRoute<void>(
          expandFrom: context,
          transitionDuration: const Duration(seconds: 1),
          builder: (context) => _ImageViewerPage(image: image),
        ));
      },
      child: Container(
        height: 80,
        width: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image(
          image: image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({
    @required this.image,
  });

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: InteractiveViewer(
        maxScale: 10,
        minScale: .5,
        child: Center(
          child: Image(
            image: image,
          ),
        ),
      ),
    );
  }
}
