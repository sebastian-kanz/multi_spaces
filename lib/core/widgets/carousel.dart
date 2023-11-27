import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final List<Widget> elements;

  const Carousel({
    super.key,
    required this.elements,
  });

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  CarouselController controller = CarouselController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: CarouselSlider(
            carouselController: controller,
            options: CarouselOptions(
              viewportFraction: 1,
              autoPlay: true,
              autoPlayCurve: Curves.bounceIn,
              autoPlayInterval: const Duration(seconds: 10),
              aspectRatio: 1.3 / 1,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: widget.elements,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: DotsIndicator(
            dotsCount: widget.elements.length,
            position: currentIndex,
            onTap: (position) => controller.animateToPage(position),
            decorator: DotsDecorator(
              activeColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
