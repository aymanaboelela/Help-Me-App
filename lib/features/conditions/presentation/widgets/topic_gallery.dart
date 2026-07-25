import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/media/topic_media.dart';
import '../../../../l10n/app_localizations.dart';

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
          height: 196,
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
              return Semantics(
                label: image.caption.resolve(locale),
                image: true,
                // A drawing is a diagram and needs its margin; a photograph is
                // a scene and should fill the frame edge to edge.
                child: image.isDrawing
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(image.asset, fit: BoxFit.contain),
                      )
                    : Image.asset(
                        image.asset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
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
        if (widget.images[_page].credit != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            '${AppLocalizations.of(context).photoBy} '
            '${widget.images[_page].credit!.photographer} · Pexels',
            style: context.texts.labelSmall?.copyWith(
              color: context.semantic.muted.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}
