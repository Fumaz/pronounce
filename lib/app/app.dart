import 'package:flutter/cupertino.dart';
import 'package:pronounce/app/page.dart';

class PronounceApp extends StatelessWidget {
  const PronounceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Pronounce',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemPink,
      ),
      home: PronouncePage()
    );
  }

}