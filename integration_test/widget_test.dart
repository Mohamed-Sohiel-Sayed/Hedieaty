// // This is a basic Flutter widgets test.
// //
// // To perform an interaction with a widgets in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widgets
// // tree, read text, and verify that the values of widgets properties are correct.
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:hedieaty/shared/widgets/custom_widgets.dart';
import 'package:integration_test/integration_test.dart';

void main(){
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    group('Testing user', (){
        // Setting up testing environment for all tests
        setUpAll(() async {
            WidgetsFlutterBinding.ensureInitialized();
            await Firebase.initializeApp();
        });
        testWidgets(
            'Integration Test Scenario',
            (WidgetTester tester) async{
                // Initializing Application
                app.main();

                /******************* Login Landing Page *******************/
                print('Login test');
                await tester.pumpAndSettle(const Duration(seconds: 5));

                expect(find.byType(AuthTextField), findsNWidgets(2));
                expect(find.byType(AuthButton), findsOneWidget);
                expect(find.byType(AuthTextButton), findsOneWidget);

                await tester.tap(find.byType(AuthTextButton));
                await tester.pumpAndSettle(const Duration(seconds: 2));
                print('Login test succeeded');

                /******************* Sign Up Page *******************/
                print('Sign up test');
                // Enterred Sign Up Page
                expect(find.byType(AuthTextField), findsNWidgets(4));
                expect(find.byType(AuthButton), findsOneWidget);
                expect(find.byType(AuthTextButton), findsOneWidget);
                
                final nameTextField = find.byType(AuthTextField).at(0);
                final emailTextField = find.byType(AuthTextField).at(1);
                final passwordTextField = find.byType(AuthTextField).at(2);
                final mobileTextField = find.byType(AuthTextField).at(3);

                await tester.enterText(nameTextField, 'Tester Name');
                await tester.enterText(emailTextField, 'tester@tester.com');
                await tester.enterText(passwordTextField, 'testerpassword');
                await tester.enterText(mobileTextField, '0123456789');
                await tester.pumpAndSettle();

                await tester.tap(find.byType(AuthButton));

                /******************* Login Page After Sign Up *******************/
                await tester.pumpAndSettle(const Duration(seconds: 2));
                print('Sign up test succeeded');
                print('Login test started');

                final loginEmail = find.byType(AuthTextField).first;
                final loginPassword = find.byType(AuthTextField).last;

                await tester.enterText(loginEmail, 'tester@tester.com');
                await tester.enterText(loginPassword, 'testerpassword');
                await tester.pumpAndSettle();

                await tester.tap(find.byType(AuthButton));
                await tester.pumpAndSettle(const Duration(seconds: 5));
                print('Login test started');
            }
        );

    });
}

// Testing Tutorial
// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());
//
//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
//
//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
//
//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }