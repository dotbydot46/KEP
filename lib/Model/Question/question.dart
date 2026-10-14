class Question {
  final String title;
  final String option1;
  final String option2;
  final String option3;
  final String option4;
  final String answer;
  final String subject;
  final int? answerIndex;
  List<String> get options => [option1, option2, option3, option4];
  int get correctOption => answerIndex ?? options.indexOf(answer);
  const Question({
    required this.title,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.answer,
    required this.subject,
    this.answerIndex,
  });
}
