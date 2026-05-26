import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/audio_service.dart';

void playBookFlipFeedback() {
  SystemSound.play(SystemSoundType.click);
  HapticFeedback.selectionClick();
  unawaited(WcAudioService.instance.playPageFlip());
}

Route<T> buildBookPageRoute<T>({
  required Widget child,
  bool reverseFlip = false,
}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 680),
    reverseTransitionDuration: const Duration(milliseconds: 520),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );

      return AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, pageChild) {
          final t = curved.value;
          final flipSign = reverseFlip ? -1.0 : 1.0;
          final fold = (1.0 - t);
          final rotation = fold * 1.08 * flipSign;
          final dim = fold * 0.30;
          final spineDepth = 14 + (22 * fold);
          final spineShift = 16 * flipSign * fold;
          final specular = 0.40 * fold;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF090E1B).withValues(alpha: 0.16),
                        const Color(0xFF090E1B).withValues(alpha: 0.02),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Transform(
                alignment: reverseFlip ? Alignment.centerLeft : Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0023)
                  ..rotateY(rotation)
                  ..rotateZ(-0.03 * flipSign * fold)
                  ..scaleByDouble(0.965 + (0.035 * t), 0.965 + (0.035 * t), 1, 1),
                child: pageChild,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    child: Transform.translate(
                      offset: Offset(spineShift, 0),
                      child: Container(
                        width: spineDepth,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF060B16).withValues(alpha: 0.48 * fold),
                              const Color(0xFF060B16).withValues(alpha: 0.08 * fold),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    child: Transform.translate(
                      offset: Offset(spineShift + (8 * flipSign), 0),
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: specular),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: dim),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
