import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:auctor_app/main.dart';
import 'package:auctor_app/premium/app.dart';
import 'package:auctor_app/premium/controller.dart';

class FixtureController extends WorkspaceController {
  FixtureController({bool signedIn = false})
      : super(
            api: PlatformApi(
                client: MockClient((r) async => http.Response('[]', 200)))) {
    loading = false;
    if (signedIn) {
      workspace = {
        'profile': {
          'handle': 'test-developer',
          'display_name': 'Alex Developer',
          'bio': 'Systems engineer',
          'role': 'developer',
          'discoverable': false,
          'preferences': {},
          'github_identity': {}
        },
        'cv': {
          'skills': ['Docker', 'REST API'],
          'projects': [
            {'name': 'Orders API', 'description': 'Transactional backend'}
          ],
          'experience': [],
          'profiles': {}
        },
        'score': {
          'total': .6,
          'components': {
            for (final key in [
              'github',
              'leetcode',
              'badges',
              'projects',
              'experience'
            ])
              key: {
                'fraction': key == 'badges' ? 0.2 : 0,
                'weight': const {
                  'github': .25,
                  'leetcode': .15,
                  'badges': .30,
                  'projects': .15,
                  'experience': .15
                }[key],
                'points': key == 'badges' ? 0.6 : 0
              }
          }
        },
        'badges': [
          {
            'badge_id': 'docker',
            'passed': true,
            'started_at': '2026-10-01T00:00:00Z',
            'submitted_at': '2026-10-01T00:01:00Z',
            'correct_count': 5,
            'score_delta': .6
          }
        ],
        'activity': [],
        'evidence': [],
        'documents': [],
        'versions': [],
        'history': [],
        'shares': []
      };
    }
  }
  @override
  Future<void> initialize() async {}
}

void main() {
  testWidgets(
      'Skill source connection opens scoped badge details and keeps unsupported claims unverified',
      (tester) async {
    final controller = WorkspaceController(
        api: PlatformApi(client: MockClient((request) async {
      expect(request.url.path, '/api/challenges/docker');
      return http.Response(
          jsonEncode({
            'name': 'Containers & delivery',
            'skill': 'Docker',
            'earned': true,
            'questions': 5,
            'pass_threshold': 3,
            'duration_seconds': 300,
            'scope': 'Passed five questions; not comprehensive competency.',
            'attempts': [
              {
                'started_at': '2026-10-01T00:00:00Z',
                'submitted_at': '2026-10-01T00:01:00Z',
                'expires_at': '2026-10-01T00:05:00Z',
                'correct_count': 5,
                'passed': true,
                'score_delta': .6
              }
            ]
          }),
          200);
    })));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          workspaceProvider.overrideWith((ref) => FixtureController())
        ],
        child: MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
                    child: EvidenceSkillsGraph(
                        controller: controller,
                        nodes: const [
              {
                'id': 'skill:docker',
                'name': 'Docker',
                'status': 'assessed',
                'sources': [
                  {
                    'id': 'badge:docker',
                    'label': 'Containers & delivery',
                    'kind': 'assessment',
                    'status': 'assessed',
                    'badge_id': 'docker',
                    'scope': 'Passed five questions only.'
                  }
                ]
              },
              {
                'id': 'skill:unknown',
                'name': 'Unknown Tool',
                'status': 'claimed',
                'sources': [
                  {
                    'id': 'cv',
                    'label': 'Current CV declaration',
                    'kind': 'cv',
                    'status': 'unverified'
                  }
                ]
              },
            ]))))));
    await tester.tap(find.text('Inspect source connection'));
    await tester.pumpAndSettle();
    expect(find.text('Badge earned'), findsOneWidget);
    expect(find.text('Passed five questions; not comprehensive competency.'),
        findsOneWidget);
    expect(find.textContaining('actual delta +0.6'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unknown Tool'));
    await tester.pumpAndSettle();
    expect(find.text('Unknown Tool · claimed'), findsOneWidget);
    expect(find.text('unverified'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('CV save failure preserves the reviewed draft for retry',
      (tester) async {
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CvEditor(
                data: const {
          'skills': ['Docker'],
          'projects': [],
          'experience': [],
          'profiles': {}
        },
                onSave: (data) async {
                  submitted = data;
                  throw ApiFailure('Server unavailable', 503);
                }))));
    await tester.enterText(find.byType(TextField).first, 'Docker, Redis');
    await tester.tap(find.text('Save reviewed CV'));
    await tester.pumpAndSettle();
    expect(submitted?['skills'], ['Docker', 'Redis']);
    expect(find.text('Review your story'), findsOneWidget);
    expect(find.text('Server unavailable'), findsOneWidget);
    expect(find.text('Docker, Redis'), findsOneWidget);
    expect(find.text('Save reviewed CV'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('API forwards bearer authentication and interprets safe failure details',
      () async {
    final api = PlatformApi(client: MockClient((req) async {
      expect(req.headers['Authorization'], 'Bearer owned-session');
      expect(req.url.path, '/api/me');
      return http.Response('{"detail":"Session expired"}', 401);
    }))
      ..token = 'owned-session';
    await expectLater(
        api.call('/me'),
        throwsA(isA<ApiFailure>()
            .having((e) => e.message, 'message', 'Session expired')));
  });
  for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
    testWidgets('Landing renders responsively at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(overrides: [
        workspaceProvider.overrideWith((ref) => FixtureController())
      ], child: const AuctorApp()));
      await tester.pumpAndSettle();
      expect(find.text('Let your work\nspeak beautifully.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Authenticated evidence journey renders at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = FixtureController(signedIn: true);
      await tester.pumpWidget(ProviderScope(
          overrides: [workspaceProvider.overrideWith((ref) => fixture)],
          child: const AuctorApp()));
      await tester.pumpAndSettle();
      expect(find.text('A clearer picture of your craft'), findsOneWidget);
      expect(tester.takeException(), isNull);
      fixture.select(1);
      await tester.pumpAndSettle();
      expect(find.text('A library of your evidence'), findsOneWidget);
      expect(find.text('Orders API'), findsOneWidget);
      expect(tester.takeException(), isNull);
      fixture.select(5);
      await tester.pumpAndSettle();
      expect(find.text('A profile that feels like you'), findsOneWidget);
      expect(find.text('Reduce motion'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
