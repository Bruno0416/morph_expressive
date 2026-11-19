import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BuildContext,
        Clip,
        RoundedRectangleBorder,
        SizedBox,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Surfaces & Content]/Carousels';

@widgetbook.UseCase(name: 'Carousel', type: MorphCarousel, path: _path)
Widget carouselUseCase(BuildContext context) {
  final type = enumKnob<MorphCarouselType>(
    context,
    label: 'type',
    values: MorphCarouselType.values,
    initial: MorphCarouselType.contained,
  );
  final count = context.knobs.int.slider(
    label: 'items',
    initialValue: 6,
    min: 2,
    max: 12,
  );
  final height = context.knobs.double.slider(
    label: 'height',
    initialValue: 200,
    min: 120,
    max: 320,
  );
  final freeScroll = context.knobs.boolean(label: 'free scroll');
  final titles = context.knobs.boolean(label: 'titles');
  return Stage(
    children: [
      SizedBox(
        height: height + 16,
        child: MorphCarousel(
          key: resetKey([type, count, freeScroll, titles]),
          type: type,
          height: height,
          freeScroll: freeScroll,
          children: [
            for (var i = 0; i < count; i++)
              MorphCarouselItem(
                onTap: () {},
                title: titles ? Text('Item ${i + 1}') : null,
                subtitle: titles ? const Text('Subtitle') : null,
                image: DemoImage(index: i),
              ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Carousel view', type: MorphCarouselView, path: _path)
Widget carouselViewUseCase(BuildContext context) {
  final snapping = context.knobs.boolean(label: 'item snapping');
  final scale = context.knobs.boolean(label: 'scale items', initialValue: true);
  final extent = context.knobs.double.slider(
    label: 'item extent',
    initialValue: 200,
    min: 100,
    max: 320,
  );
  final infinite = context.knobs.boolean(label: 'infinite');
  final weighted = context.knobs.boolean(label: 'weighted');
  const items = 8;
  final children = [for (var i = 0; i < items; i++) DemoImage(index: i)];
  return Stage(
    children: [
      SizedBox(
        height: 200,
        child: weighted
            ? MorphCarouselView.weighted(
                key: resetKey([snapping, scale, infinite, weighted]),
                itemSnapping: snapping,
                scaleItems: scale,
                infinite: infinite,
                flexWeights: const [1, 7, 1],
                children: children,
              )
            : MorphCarouselView(
                key: resetKey([snapping, scale, infinite, weighted, extent]),
                itemSnapping: snapping,
                scaleItems: scale,
                infinite: infinite,
                itemExtent: extent,
                children: children,
              ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Wrapper and show all',
  type: MorphCarouselWrapper,
  path: _path,
)
Widget carouselWrapperUseCase(BuildContext context) {
  final children = [
    for (var i = 0; i < 6; i++)
      MorphCarouselItem(
        image: DemoImage(index: i),
        title: Text('Slide ${i + 1}'),
      ),
  ];
  return Stage(
    children: [
      StageSection(
        title: 'MorphCarouselWrapper',
        child: SizedBox(
          height: 200,
          child: MorphCarouselWrapper(
            itemExtent: 220,
            itemClipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            children: children,
          ),
        ),
      ),
      StageSection(
        title: 'MorphCarouselShowAll',
        child: SizedBox(
          height: 360,
          child: MorphCarouselShowAll(
            header: const Text('All items'),
            children: [
              for (var i = 0; i < 6; i++)
                MorphCarouselItem(
                  image: DemoImage(index: i),
                  title: Text('Item ${i + 1}'),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
