import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'tasks_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.toHSL.withLightness(.4).toColor(),
      body: RotatingDrawer(
        drawerWidth: 300,
        header: (context, animation) => AppBar(
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: RotatingDrawerState.of(context).toggle,
            );
          }),
          title: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Opacity(
              opacity: 1 - animation.value,
              child: const Text('Home'),
            ),
          ),
        ),
        drawer: Material(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Tasks'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TasksPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Container(color: Colors.white),
      ),
    );
  }
}

extension on Color {
  HSLColor get toHSL => HSLColor.fromColor(this);
}
