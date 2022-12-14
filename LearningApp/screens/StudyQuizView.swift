
import SwiftUI

struct StudyQuizView: View {
    
    var studyItem : StudyItem
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertMessage : String = ""
    @State private var startDate = Date()
    @State private var selectedAnswer : String = ""
    @State private var shuffledAnswers : [String] = []
    @State private var didSubmitAnswer = false
    
    var body: some View {
        VStack {
            Group {
                Text(studyItem.question)
                    .font(.system(size: 20))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                List {
                    ForEach(shuffledAnswers, id: \.self) { distractor in
                        AnswerCell(answer: distractor,
                                   isCorrectAnswer: distractor == studyItem.answer,
                                   isSelected: distractor == selectedAnswer,
                                   didSubmitAnswer: didSubmitAnswer,
                                   onPressed: onAnswerPressed)
                    }
                }.scrollContentBackground(.hidden)
            }
            Spacer()
            Button(didSubmitAnswer ? "Done" : "Submit") {
                if (didSubmitAnswer) {
                    dismiss()
                } else {
                    sendStudyReport()
                }
            }.font(.system(size: 20))
                .padding()
                .background(Color.primaryRed)
                .foregroundColor(.white)
                .cornerRadius(5)
        }
        .background(Color.lightGrey)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Oops"),
                  message: Text(alertMessage),
                  dismissButton: .cancel(Text("OK")))
        }
        .navigationTitle("Quiz").onAppear() {
            startDate = Date()
        }
        .onAppear() {
            shuffledAnswers = studyItem.getShuffledAnswers()
        }
    }
    
    private func onAnswerPressed(answer: String) {
        selectedAnswer = answer
    }
    
    private func sendStudyReport() {
        let now = Date()
        let studyTime = now.timeIntervalSince(startDate) * 1000
        let quizResult: QuizResult = (selectedAnswer == studyItem.answer) ? .Correct : .Incorrect
        MemreLearningEngine.postStudyReport(itemId: studyItem.learningEngineId,
                                            quizResult: quizResult,
                                            studyTimeMillis: studyTime,
                                            onCompletion: onPostStudyReport,
                                            onError: onPostStudyReportError)
    }
    
    private func onPostStudyReport() {
        didSubmitAnswer = true
    }
    
    private func onPostStudyReportError(errorMessage: String) {
        alertMessage = errorMessage
        showingAlert = true
    }
}

struct StudyQuizView_Previews: PreviewProvider {
    
    static var previews: some View {
        StudyQuizView(studyItem: StudyItem.previewStudyItem())
    }
}
