import 'package:circular_clip_route/circular_clip_route.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class _PageBody extends StatelessWidget {
  const _PageBody({
    @required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(color: Colors.white),
      child: child.padding(all: 20),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    @required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 32),
      child: child,
    ).padding(bottom: 20);
  }
}

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: _PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageTitle(child: Text("Today's Task")),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marathon Running Prep'),
                const Spacer(),
                Transform.translate(
                  offset: const Offset(14, -14),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.insert_chart,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          CircularClipRoute<void>(
                            expandFrom: context,
                            builder: (_) => _TaskProgressPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: _PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageTitle(child: Text('My Progress')),
            const Text('Completed Tasks'),
          ],
        ),
      ),
    );
  }
}
