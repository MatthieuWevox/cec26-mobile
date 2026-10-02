import 'package:cec2026/providers/auth_provider.dart';
import 'package:cec2026/models/member.dart';
import 'package:cec2026/screens/private/private_home_screen.dart';
import 'package:cec2026/screens/main_screen.dart';
import 'package:cec2026/screens/news/news_screen.dart';
import 'package:cec2026/screens/private/login_screen.dart';
import 'package:cec2026/theme/app_theme.dart';
import 'package:cec2026/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'espace membre : les actions restent accessibles sur petit écran',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => _MemberTestAuth(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const PrivateHomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('Mon profil'), 220);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mon profil'));
      await tester.pumpAndSettle();
      expect(find.text('Enregistrer'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('le design system affiche une action principale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Continuer'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continuer'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('un panneau vitré applique un flou réel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: CecBackground(
            child: Center(
              child: CecGlassPanel(
                padding: EdgeInsets.all(16),
                child: Text('Contenu premium'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('Contenu premium'), findsOneWidget);
  });

  testWidgets('une surface tactile conserve son action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CecSurface(
            onTap: () => tapped = true,
            child: const Text('Ouvrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('les révélations respectent la réduction des animations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: CecReveal(child: Text('Sans mouvement imposé')),
        ),
      ),
    );
    await tester.pump();

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));

    expect(opacity.duration, Duration.zero);
    expect(slide.duration, Duration.zero);
    expect(opacity.opacity, 1);
  });

  testWidgets('le démarrage est public et la connexion reste dans son onglet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MainScreen(),
        ),
      ),
    );

    expect(find.byType(NewsScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Découvrir le Club sans compte'), findsNothing);

    await tester.tap(find.text('Connexion'));
    await tester.pump(AppTheme.motion);

    final navigationSize = tester.getSize(
      find.byKey(const Key('main-navigation-panel')),
    );
    expect(navigationSize.width, lessThanOrEqualTo(390));
    expect(navigationSize.height, lessThan(100));
    expect(find.text('Heureux de\nvous retrouver.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Découvrir le Club sans compte'), findsNothing);
    await tester.tap(find.text('Le Club'));
    await tester.pump(AppTheme.motion);
    expect(find.byType(NewsScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('effacer la recherche actualise le filtre et conserve le focus', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CecSearchField(hintText: 'Rechercher', onChanged: changes.add),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'CEC');
    await tester.pump();
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pump();
    expect(changes, ['CEC', '']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('petit téléphone : texte agrandi et clavier sans débordement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const MainScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Connexion'));
    await tester.pump(AppTheme.motion);
    expect(tester.takeException(), isNull);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    await tester.pump(AppTheme.motion);
    expect(find.byKey(const Key('main-navigation-panel')), findsNothing);
    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'Se connecter'),
      180,
      scrollable: find
          .descendant(
            of: find.byType(LoginScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

class _MemberTestAuth extends AuthProvider {
  @override
  bool get isLoggedIn => true;

  @override
  Member get currentMember => const Member(
    id: 1,
    nom: 'Exemple',
    prenom: 'Camille',
    email: 'camille@example.test',
    createdAt: '',
    updatedAt: '',
  );
}
