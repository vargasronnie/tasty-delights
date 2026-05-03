// // import 'package:device_preview/device_preview.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'bloc/app_bloc.dart';
// // import 'theme/app_theme.dart';
// // import 'views/auth/login_view.dart';
// // import 'presenters/main_shell.dart';

// // class TastyDelightsApp extends StatelessWidget {
// //   const TastyDelightsApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Tasty Delights',
// //       debugShowCheckedModeBanner: false,
// //       theme: AppTheme.lightTheme,
// //       locale: DevicePreview.locale(context),
// //       builder: DevicePreview.appBuilder,
// //       home: const _AuthGate(),
// //     );
// //   }
// // }

// // class _AuthGate extends StatelessWidget {
// //   const _AuthGate();

// //   @override
// //   Widget build(BuildContext context) {
// //     final bloc = context.watch<AppBloc>();

// //     if (bloc.isLoading && bloc.currentUser == null) {
// //       return const Scaffold(
// //         body: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.restaurant, size: 64, color: AppTheme.primary),
// //               SizedBox(height: 16),
// //               Text('Tasty Delights',
// //                   style: TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.w800,
// //                       color: AppTheme.textDark)),
// //               SizedBox(height: 24),
// //               CircularProgressIndicator(color: AppTheme.primary),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (bloc.currentUser == null) {
// //       return const LoginView();
// //     }

// //     return const MainShell();
// //   }
// // }

// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'bloc/app_bloc.dart';
// import 'theme/app_theme.dart';
// import 'views/auth/login_view.dart';
// import 'presenters/main_shell.dart';

// class TastyDelightsApp extends StatelessWidget {
//   const TastyDelightsApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Tasty Delights',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       locale: DevicePreview.locale(context),
//       builder: DevicePreview.appBuilder,
//       home: const _AuthGate(),
//     );
//   }
// }

// class _AuthGate extends StatefulWidget {
//   const _AuthGate();

//   @override
//   State<_AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<_AuthGate> {
//   // Safety: force stop loading after 8 seconds no matter what
//   bool _forceReady = false;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 8), () {
//       if (mounted && context.read<AppBloc>().isLoading) {
//         context.read<AppBloc>(); // trigger re-check
//         setState(() => _forceReady = true);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bloc = context.watch<AppBloc>();

//     if (bloc.isLoading && !_forceReady) {
//       return const _SplashScreen();
//     }

//     if (bloc.currentUser == null) {
//       return const LoginView();
//     }

//     return const MainShell();
//   }
// }

// class _SplashScreen extends StatelessWidget {
//   const _SplashScreen();

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: AppTheme.background,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.restaurant, size: 60, color: AppTheme.primary),
//             SizedBox(height: 14),
//             Text(
//               'Tasty Delights',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 color: AppTheme.textDark,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Loading your experience...',
//               style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
//             ),
//             SizedBox(height: 24),
//             SizedBox(
//               width: 32,
//               height: 32,
//               child: CircularProgressIndicator(
//                   color: AppTheme.primary, strokeWidth: 3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bloc/app_bloc.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'presenters/main_shell.dart';

class TastyDelightsApp extends StatelessWidget {
  const TastyDelightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasty Delights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      // Use Firebase auth stream directly — no manual isLoading needed
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Still connecting to Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }

          // User is logged in
          if (snapshot.hasData && snapshot.data != null) {
            // Trigger data load in background
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AppBloc>().loadAfterAuth(snapshot.data!.uid);
            });
            return const MainShell();
          }

          // Not logged in
          return const LoginView();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 60, color: AppTheme.primary),
            SizedBox(height: 14),
            Text(
              'Tasty Delights',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
