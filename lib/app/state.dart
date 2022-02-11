import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pronounce/app/page.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PronounceState extends State<PronouncePage> {
  Set<String> words = {};

  SpeechToText speech = SpeechToText();
  String? currentWord;
  String? spelledWord;
  bool enabled = false;
  int howManyWords = 1;

  void loadWords() async {
    print('Loading words...');
    final words =
        await DefaultAssetBundle.of(context).loadString('assets/words');
    final lines = words.split('\n');

    for (final line in lines) {
      final word = line.trim();
      if (word.isNotEmpty) {
        this.words.add(word);
      }
    }

    print('Loaded ${this.words.length} words.');
    chooseWord();
  }

  void chooseWord() {
    print('Choosing word...');

    setState(() {
      speech.stop();
      StringBuffer buffer = StringBuffer();

      for (int i = 0; i < howManyWords; i++) {
        if (i != 0) {
          buffer.write(' ');
        }

        final word = words.elementAt(Random().nextInt(words.length));
        buffer.write(word);
      }

      currentWord = buffer.toString();
      spelledWord = null;
    });
  }

  @override
  void initState() {
    super.initState();
    print('Initializing state');
    initSpeech();
    loadWords();
  }

  void initSpeech() async {
    print('Initializing speech...');

    enabled = await speech.initialize();
    setState(() {
      print('Speech initialized');
    });
  }

  void speak() async {
    await speech.listen(onResult: (result) {
      setState(() {
        spelledWord = result.recognizedWords;

        if (spelledWord?.split(" ").length != howManyWords) {
          return;
        }

        speech.stop();
      });
    }, listenFor: Duration(seconds: 10));

    setState(() {
    });
  }

  void chooseHowManyWords() {
    FixedExtentScrollController controller = FixedExtentScrollController(initialItem: howManyWords - 1);

    showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
            height: 200,
            child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 30,
                onSelectedItemChanged: (index) {
                  setState(() {
                    howManyWords = index + 1;
                  });
                },
                backgroundColor: CupertinoColors.systemBackground,
                children: <Widget>[
                  for (int i = 0; i < 5; i++)
                    Text((i + 1).toString() + " words")
                ])));
  }

  @override
  Widget build(BuildContext context) {
    Color spelledColor = (spelledWord?.toLowerCase() == currentWord?.toLowerCase())
        ? CupertinoColors.activeGreen
        : CupertinoColors.destructiveRed;

    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            onPressed: () {
              chooseHowManyWords();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(howManyWords.toString() + " words", style: TextStyle(fontSize: 25),),
                const Icon(CupertinoIcons.down_arrow),
              ]
            )
          ),
          const Text("You need to pronounce", style: TextStyle(fontSize: 35),),
          Text(currentWord ?? "no word", style: const TextStyle(fontSize: 45, color: CupertinoColors.systemYellow), textAlign: TextAlign.center),
          const Text("You pronounced", style: TextStyle(fontSize: 35)),
          Text((spelledWord ?? "no word").toLowerCase(), style: TextStyle(fontSize: 45, color: spelledColor), textAlign: TextAlign.center),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                  child: Text(speech.isListening ? "Speaking..." : "Speak", style: TextStyle(fontSize: 25)),
                  onPressed: () {
                    if (speech.isListening) {
                      speech.stop();
                    }

                    speak();
                  }),
              CupertinoButton(
                  child: const Text("Next", style: TextStyle(fontSize: 25)),
                  onPressed: () {
                    chooseWord();
                  }),
            ],
          )
        ],
      ),
    );
  }
}
