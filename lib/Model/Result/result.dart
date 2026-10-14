class Result {
  int total = 0;
  int correct = 0;
  int wrong = 0;
  int getCorrectAns() => correct;
  int getWrongAns() => wrong;
  int getTotalQuestions() => total;
  int notAttempted() => (total - correct - wrong).clamp(0, total);
  double percentage() => total == 0 ? 0 : correct / total * 100;
}
