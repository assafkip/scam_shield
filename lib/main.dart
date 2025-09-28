import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'pages/scenario_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScamShieldApp());
}

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState()..initializeApp(),
      child: MaterialApp(
        title: 'ScamShield',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
          ).copyWith(
            primary: const Color(0xFF2196F3),
            error: const Color(0xFFFF4444),
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              shadowColor: Colors.black26,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2196F3),
              side: const BorderSide(color: Color(0xFF2196F3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: const Color(0xFF00C851),
            inactiveTrackColor: const Color(0xFFFF4444).withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF2196F3).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            trackHeight: 6,
          ),
          extensions: [
            CustomColors(
              success: const Color(0xFF00C851),
              warning: const Color(0xFFFFD600),
            ),
          ],
        ),
        home: const ScenarioPickerPage(),
      ),
    );
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color warning;

  const CustomColors({
    required this.success,
    required this.warning,
  });

  @override
  CustomColors copyWith({
    Color? success,
    Color? warning,
  }) {
    return CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
