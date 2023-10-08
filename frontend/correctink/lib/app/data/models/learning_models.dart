class LearningWrittenReport {
  late bool correct = true;
  late int distance = 0;
  late bool noError = true;
  late List<ReportPayload> payload = <ReportPayload>[];
}

class ReportPayload {
  final String answerSpan;
  final bool correct;

  ReportPayload (this.answerSpan, this.correct);
}