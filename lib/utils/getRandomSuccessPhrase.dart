import 'dart:math';

String getRandomSuccessPhrase() {
  final List<String> successWords = [
    'Astonishing!',
    'Well done!',
    'Magic!',
    'Voila!',
    'Easy peazy.',
    'Solved!'
  ];

  // Generate a random index
  var randomIndex = Random().nextInt(successWords.length);

  // Return the success word at the random index
  return successWords[randomIndex];
}
