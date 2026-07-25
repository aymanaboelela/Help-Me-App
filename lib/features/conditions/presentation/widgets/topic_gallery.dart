import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/media/topic_media.dart';

/// The step illustrations for a topic, swipeable, with the caption underneath.
///
/// Captions are the teaching part: the drawing shows the shape of the action and
/// the caption says the thing that is easy to get wrong.
class TopicGallery extends StatefulWidget {
  const TopicGallery({super.key, required this.images, required this.accent});

  final List<TopicImage> images;
  final Color accent;

  @override
  State<TopicGallery> createState() => _TopicGalleryState();
}

class _TopicGalleryState extends State<TopicGallery> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = context.locale;
    final bool many = widget.images.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 186,
          decoration: BoxDecoration(
            color: widget.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (int i) => setState(() => _page = i),
            itemBuilder: (BuildContext context, int i) {
              final TopicImage image = widget.images[i];
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Semantics(
                  label: image.caption.resolve(locale),
                  image: true,
                  child: SvgPicture.asset(image.asset, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
        if (many) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < widget.images.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? widget.accent
                        : widget.accent.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Text(
          widget.images[_page].caption.resolve(locale),
          style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
        ),
      ],
    );
  }
}
