import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cec2026/models/member.dart';
import 'package:cec2026/screens/companies/company_detail_screen.dart';
import 'package:cec2026/theme/app_theme.dart';
import 'package:cec2026/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _logoUrl = 'https://example.test/logo.png';
const _bannerUrl = 'https://example.test/banner.png';
const _captureKey = Key('capture');

void _cacheImage(String url, Color color) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawPaint(Paint()..color = color);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(16, 16);
  picture.dispose();
  PaintingBinding.instance.imageCache.putIfAbsent(
    CachedNetworkImageProvider(url),
    () => OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image))),
  );
}

Future<void> _expectLogoPainted(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  final center = boundary.globalToLocal(
    tester.getCenter(find.byType(CompanyLogo).last),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final pixels = (await image.toByteData())!;
    final offset = (center.dy.floor() * image.width + center.dx.floor()) * 4;
    // The logo must be painted over the banner, without its tint or opacity.
    expect(pixels.buffer.asUint8List(offset, 4), [0, 255, 0, 255]);
    image.dispose();
  });
}

void main() {
  for (final width in [320.0, 390.0]) {
    for (final hasBanner in [false, true]) {
      testWidgets('company logo foreground: width=$width banner=$hasBanner', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(PaintingBinding.instance.imageCache.clear);
        _cacheImage(_logoUrl, const Color(0xFF00FF00));
        _cacheImage(_bannerUrl, const Color(0xFFFF0000));
        final company = Company(
          id: 1,
          nom: 'Entreprise test',
          logoUrl: _logoUrl,
          photoUrl: hasBanner ? _bannerUrl : null,
          description: List.filled(
            80,
            'Description de l entreprise.',
          ).join(' '),
          createdAt: '',
          updatedAt: '',
        );
        await tester.pumpWidget(
          RepaintBoundary(
            key: _captureKey,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(padding: const EdgeInsets.only(top: 44, bottom: 34)),
                child: child!,
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CompanyDetailScreen(company: company),
                      ),
                    ),
                    child: const Hero(
                      tag: 'company-logo-1',
                      child: CompanyLogo(
                        logoUrl: _logoUrl,
                        companyName: 'Entreprise test',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CompanyLogo));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.descendant(
            of: find.byType(FlexibleSpaceBar),
            matching: find.byType(CompanyLogo),
          ),
          findsNothing,
        );
        expect(
          find.byKey(const Key('company-logo-foreground')),
          findsOneWidget,
        );
        final logo = tester.getRect(find.byType(CompanyLogo));
        expect(logo.size, const Size(80, 80));
        if (hasBanner) {
          final banner = tester.getRect(
            find.byKey(const Key('company-banner')),
          );
          expect(logo.top, lessThan(banner.bottom));
          expect(logo.bottom, banner.bottom + 32);
        }
        expect(
          logo.top,
          greaterThan(tester.getBottomLeft(find.byType(BackButton)).dy),
        );
        await _expectLogoPainted(tester);

        final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
        scroll.position.jumpTo(40);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byType(CompanyLogo)).bottom,
          logo.bottom - 40,
        );
        if (hasBanner) await _expectLogoPainted(tester);

        scroll.position.jumpTo(300);
        await tester.pumpAndSettle();
        expect(find.byType(CompanyLogo).hitTestable(), findsNothing);
        expect(find.byType(BackButton).hitTestable(), findsOneWidget);
        scroll.position.jumpTo(0);
        await tester.pumpAndSettle();
        await _expectLogoPainted(tester);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(CompanyDetailScreen), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
