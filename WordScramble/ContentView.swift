//
//  ContentView.swift
//  WordScramble
//
//  Created by csuftitan on 2/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
//                    attribute to disable autocorrection
                        .disableAutocorrection(true)
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New game", action: startGame)
            }
            .safeAreaInset(edge: .bottom) {
                Color.blue
                .edgesIgnoringSafeArea(.bottom)
                .frame(height: 70)
                .overlay(
                    Text("Score: \(score)")
                        .font(.title)
                        .foregroundColor(.white)
                )
            }
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isThreeLetters(word: answer) else {
            wordError(title: "Word too short", message: "Word must have at least 3 letters")
            return
        }
        
        guard isBaseWord(word: answer) else {
            wordError(title: "Nice try...", message: "The answer cannot be the question")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        changeScore(word: answer)
            
        newWord = ""
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0 // reset the score on a new game
                usedWords.removeAll()
                newWord = ""
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isThreeLetters(word: String) -> Bool {
        word.count < 3 ? false: true
    }
    
    func isBaseWord(word: String) -> Bool {
        word == rootWord ? false: true
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func changeScore(word: String) {
        if word.count == 8 {
            score += 100
        }
        else if word.count > 5 {
            score += 75
        }
        else if word.count > 3 {
            score += 50
        }
        else {
            score += 25
        }
    }
}

#Preview {
    ContentView()
}
