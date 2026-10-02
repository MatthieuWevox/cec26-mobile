import 'dart:async';
import 'dart:convert';
import 'package:cec2026/models/member.dart';
import 'package:cec2026/models/meeting.dart';
import 'package:cec2026/providers/auth_provider.dart';
import 'package:cec2026/screens/companies/companies_screen.dart';
import 'package:cec2026/screens/meetings/meeting_detail_screen.dart';
import 'package:cec2026/screens/private/recommendations_screen.dart';
import 'package:cec2026/screens/private/thanks_screen.dart';
import 'package:cec2026/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _member = Member(
  id: 2,
  nom: 'Exemple',
  prenom: 'Alice',
  email: 'alice@example.test',
  createdAt: '',
  updatedAt: '',
);
const _meeting = Meeting(
  id: 7,
  date: '2026-12-10',
  heure: '08:30:00',
  adresse: 'Lieu de test',
  ordreDuJour: 'Projets communs',
  compteRendu: 'Compte rendu de test',
  createdAt: '',
  updatedAt: '',
  guests: [],
);

class _Auth extends AuthProvider {
  @override
  bool get isLoggedIn => true;
  @override
  String get token => 'test-token';
  @override
  Member get currentMember => const Member(
    id: 1,
    nom: 'Test',
    prenom: 'Camille',
    email: 'test@example.test',
    createdAt: '',
    updatedAt: '',
  );
}

Widget _app(Widget page) => ChangeNotifierProvider<AuthProvider>(
  create: (_) => _Auth(),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('fr'),
    supportedLocales: const [Locale('fr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.3)),
      child: child!,
    ),
    home: Scaffold(body: page),
  ),
);

Future<void> _smallPhone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(320, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'directory: search, clear and member segment preserve real results',
    (tester) async {
      await _smallPhone(tester);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_app(const CompaniesScreen()));
          await tester.pumpAndSettle();
          expect(find.text('Entreprise exemple'), findsOneWidget);
          expect(
            tester.widget<Text>(find.text('Tous')).style!.color,
            Colors.white,
          );
          final activityLabel = find.descendant(
            of: find.byType(ChoiceChip),
            matching: find.text('Conseil'),
          );
          expect(
            tester.widget<Text>(activityLabel).style!.color,
            AppTheme.primaryColor,
          );
          await tester.tap(activityLabel);
          await tester.pumpAndSettle();
          expect(tester.widget<Text>(activityLabel).style!.color, Colors.white);
          await tester.tap(find.text('Tous'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'absente');
          await tester.pumpAndSettle();
          expect(find.text('Entreprise exemple'), findsNothing);
          await tester.tap(find.byTooltip('Effacer la recherche'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Membres'));
          await tester.pumpAndSettle();
          expect(find.text('Alice Exemple'), findsOneWidget);
          tester.view.viewInsets = const FakeViewPadding(bottom: 260);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
        () => MockClient(
          (r) async => http.Response(
            jsonEncode(
              r.url.path.endsWith('/companies')
                  ? [
                      {
                        'id': 1,
                        'nom': 'Entreprise exemple',
                        'activites': 'Conseil',
                        'created_at': '',
                        'updated_at': '',
                      },
                    ]
                  : [_member.toJson()],
            ),
            200,
          ),
        ),
      );
    },
  );

  testWidgets(
    'recommendation: preselected recipient, validation and one authenticated send',
    (tester) async {
      await _smallPhone(tester);
      final sent = <Map<String, dynamic>>[];
      var completed = false;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            _app(
              CreateRecommendationSheet(
                initialRecipient: _member,
                onCreated: () => completed = true,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.textContaining('Alice Exemple'), findsWidgets);
          await tester.enterText(_field('Prénom du contact *'), 'Jean');
          await tester.enterText(_field('Nom du contact *'), 'Dupont');
          await tester.scrollUntilVisible(
            find.text('Envoyer la recommandation'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Envoyer la recommandation'));
          await tester.pumpAndSettle();
          expect(sent, hasLength(1));
          expect(sent.single['recommande_id'], 2);
          expect(sent.single['nom_contact'], 'Dupont');
          expect(completed, isTrue);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((r) async {
          if (r.method == 'GET') {
            return http.Response(jsonEncode([_member.toJson()]), 200);
          }
          expect(r.headers['Authorization'], 'Bearer test-token');
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          sent.add(body);
          return http.Response(
            jsonEncode({
              ...body,
              'id': 1,
              'recommandateur_id': 1,
              'created_at': '',
              'updated_at': '',
            }),
            201,
          );
        }),
      );
    },
  );

  testWidgets(
    'thanks: amount normalization, date selection and authenticated send',
    (tester) async {
      final sent = <Map<String, dynamic>>[];
      await _smallPhone(tester);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            _app(
              CreateThanksSheet(initialRecipient: _member, onCreated: () {}),
            ),
          );
          await tester.pumpAndSettle();
          await tester.enterText(_field('Montant HT (€) *'), '1200,50');
          await tester.ensureVisible(find.text('Date de l’affaire *'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Date de l’affaire *'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Envoyer le remerciement'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Envoyer le remerciement'));
          await tester.pumpAndSettle();
          expect(sent, hasLength(1));
          expect(sent.single['montant_ht'], '1200.50');
          expect(sent.single['remercie_id'], 2);
          expect(
            sent.single['date_affaire'],
            matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
          );
          expect(tester.takeException(), isNull);
        },
        () => MockClient((r) async {
          if (r.method == 'GET') {
            return http.Response(jsonEncode([_member.toJson()]), 200);
          }
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          sent.add(body);
          return http.Response(
            jsonEncode({
              ...body,
              'id': 1,
              'remerciant_id': 1,
              'created_at': '',
              'updated_at': '',
            }),
            201,
          );
        }),
      );
    },
  );

  testWidgets(
    'guest: prevents duplicate submissions and preserves source guest list',
    (tester) async {
      var sends = 0;
      final response = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            _app(const MeetingDetailScreen(meeting: _meeting)),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Ajouter un invité'));
          await tester.pumpAndSettle();
          await tester.enterText(_field('Prénom *'), 'Jean');
          await tester.enterText(_field('Nom *'), 'Dupont');
          await tester.ensureVisible(find.text('Ajouter l’invité'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Ajouter l’invité'));
          await tester.pump();
          await tester.tap(find.text('Ajout en cours…'));
          expect(sends, 1);
          response.complete(
            http.Response(
              jsonEncode({
                'id': 1,
                'prenom': 'Jean',
                'nom': 'Dupont',
                'created_at': '',
                'updated_at': '',
              }),
              201,
            ),
          );
          await tester.pumpAndSettle();
          expect(_meeting.guests, isEmpty);
          await tester.scrollUntilVisible(find.text('Jean Dupont'), 200);
          await tester.pumpAndSettle();
          expect(find.text('Jean Dupont'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
        () => MockClient((r) {
          expect(r.url.path, '/api/meetings/7/guests');
          expect(r.headers['Authorization'], 'Bearer test-token');
          sends++;
          return response.future;
        }),
      );
    },
  );

  for (final recommendation in [true, false]) {
    testWidgets(
      'exchange detail and sent tab on small phone: recommendation=$recommendation',
      (tester) async {
        await _smallPhone(tester);
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              _app(
                recommendation
                    ? const RecommendationsScreen()
                    : const ThanksScreen(),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.tap(find.text('Alice Exemple'));
            await tester.pumpAndSettle();
            expect(
              find.text(recommendation ? 'Le contexte' : 'Le message'),
              findsOneWidget,
            );
            expect(find.byTooltip('Signaler'), findsOneWidget);
            expect(tester.takeException(), isNull);
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle();
            await tester.tap(
              find.text(recommendation ? 'Envoyées' : 'Envoyés'),
            );
            await tester.pumpAndSettle();
            expect(
              find.text(
                recommendation
                    ? 'Aucune recommandation envoyée.'
                    : 'Aucun remerciement envoyé.',
              ),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
          },
          () => MockClient(
            (r) async => http.Response(
              jsonEncode(
                r.url.path.endsWith('/sent')
                    ? []
                    : [
                        {
                          'id': 5,
                          'nom_contact': 'Dupont',
                          'prenom_contact': 'Jean',
                          'email': 'jean@example.test',
                          'telephone': '0102030405',
                          'recommande_id': 1,
                          'recommandateur_id': 2,
                          'remerciant_id': 2,
                          'remercie_id': 1,
                          'montant_ht': '1200.50',
                          'date_affaire': '2026-10-01',
                          'description':
                              'Un message de contexte assez long pour vérifier sa lecture sur un petit écran.',
                          'recommandateur': _member.toJson(),
                          'remerciant': _member.toJson(),
                          'created_at': '2026-10-01',
                          'updated_at': '2026-10-01',
                        },
                      ],
              ),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
          ),
        );
      },
    );
  }

  testWidgets('recipient loading can finish after leaving the form', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      await tester.pumpWidget(
        _app(CreateRecommendationSheet(onCreated: () {})),
      );
      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      response.completeError(Exception('Offline'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, () => MockClient((_) => response.future));
  });
}
