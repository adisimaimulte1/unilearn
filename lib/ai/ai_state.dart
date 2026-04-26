import 'package:flutter/material.dart';

enum AIState {
  idle,
  listening,
  thinking,
  speaking,
}

final ValueNotifier<AIState> assistantState =
ValueNotifier(AIState.idle);

final ValueNotifier<String> liveTranscript =
ValueNotifier('');