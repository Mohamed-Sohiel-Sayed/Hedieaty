import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  RefreshableWidget({required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final RefreshController _refreshController = RefreshController(initialRefresh: false);

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () async {
        await onRefresh();
        _refreshController.refreshCompleted();
      },
      child: child,
    );
  }
}