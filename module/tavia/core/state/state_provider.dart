import 'package:flutter/material.dart';
import 'package:tavia/tavia/shared/models/content_model.dart';
import 'package:tavia/tavia/shared/models/user_model.dart';

import 'app_state.dart';

/// State provider helpers for stream-based UI.
class StateProvider extends InheritedWidget {
  final AppState state;

  const StateProvider({
    required this.state,
    required super.child,
    super.key,
  });

  static AppState of(BuildContext context) {
    final StateProvider? provider =
        context.dependOnInheritedWidgetOfExactType<StateProvider>();
    assert(provider != null, 'No StateProvider found in context');
    return provider!.state;
  }

  @override
  bool updateShouldNotify(StateProvider oldWidget) {
    return state != oldWidget.state;
  }
}

class StreamUserWidget extends StatelessWidget {
  final Widget Function(BuildContext context, UserModel?) builder;
  final Widget? loadingWidget;

  const StreamUserWidget({
    super.key,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final state = StateProvider.of(context);
    return StreamBuilder<UserModel?>(
      stream: state.userStream,
      initialData: state.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            loadingWidget != null) {
          return loadingWidget!;
        }
        return builder(context, snapshot.data);
      },
    );
  }
}

class StreamHomeFeedWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<ContentModel>) builder;
  final Widget? loadingWidget;

  const StreamHomeFeedWidget({
    super.key,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final state = StateProvider.of(context);
    return StreamBuilder<List<ContentModel>>(
      stream: state.homeFeedStream,
      initialData: state.homeFeed,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            loadingWidget != null) {
          return loadingWidget!;
        }
        return builder(context, snapshot.data ?? []);
      },
    );
  }
}

class StreamHistoryWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<ContentModel>) builder;
  final Widget? loadingWidget;

  const StreamHistoryWidget({
    super.key,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final state = StateProvider.of(context);
    return StreamBuilder<List<ContentModel>>(
      stream: state.historyStream,
      initialData: state.history,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData &&
            loadingWidget != null) {
          return loadingWidget!;
        }
        return builder(context, snapshot.data ?? []);
      },
    );
  }
}

class StreamCoinBalanceWidget extends StatelessWidget {
  final Widget Function(BuildContext context, int) builder;

  const StreamCoinBalanceWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final state = StateProvider.of(context);
    return StreamBuilder<int>(
      stream: state.coinBalanceStream,
      initialData: state.coinBalance,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? 0);
      },
    );
  }
}

class StreamLoadingWidget extends StatelessWidget {
  final Widget Function(BuildContext context, bool) builder;

  const StreamLoadingWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final state = StateProvider.of(context);
    return StreamBuilder<bool>(
      stream: state.globalLoadingStream,
      initialData: state.isGlobalLoading,
      builder: (context, snapshot) {
        return builder(context, snapshot.data ?? false);
      },
    );
  }
}
