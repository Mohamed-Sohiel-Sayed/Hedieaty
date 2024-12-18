import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/event_list/event_list_page.dart';
import 'views/gift_list/gift_list_page.dart';
import 'views/gift_details/gift_details_page.dart';
import 'views/profile/profile_page.dart';
import 'views/pledged_gifts/pledged_gifts_page.dart';
import 'views/auth/sign_in_page.dart';
import 'views/auth/sign_up_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String eventList = '/event_list';
  static const String giftList = '/gift_list';
  static const String giftDetails = '/gift_details';
  static const String profile = '/profile';
  static const String myPledgedGifts = '/my_pledged_gifts';
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _createRoute(HomePage());
      case eventList:
        final userId = settings.arguments as String;
        return _createRoute(EventListPage(userId: userId));
      case giftList:
        final args = settings.arguments as Map<String, String>;
        return _createRoute(GiftListPage(eventId: args['eventId']!, userId: args['userId']!));
      case giftDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(GiftDetailsPage(gift: args['gift'], userId: args['userId']));
      case profile:
        return _createRoute(ProfilePage());
      case myPledgedGifts:
        return _createRoute(PledgedGiftsPage());
      case signIn:
        return _createRoute(SignInPage());
      case signUp:
        return _createRoute(SignUpPage());
      default:
        return _createRoute(HomePage());
    }
  }

  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}