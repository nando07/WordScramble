//
//  ContentView.swift
//  WordScramble
//
//  Created by Fernando Gomez on 1/19/23.
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
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                Text("Score: \(score)")
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Word") {
                        startGame()
                    }
                }
            }
            .onSubmit {
                addNewWord()
                
            }
            .onAppear {
                startGame()
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
                
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    
    func getScore() {
        
        var temp = 0
        for word in usedWords {
            temp += word.count
        }
        score = temp + usedWords.count
        temp = 0
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        
        guard lessThanThreeWords(word: answer) else {
            wordError(title: "To short!", message: "Words need to have three or more letters")
            return
        }
        
        guard sameAsStartWord(word: answer) else {
            wordError(title: "Same word!", message: "You can't use the same word!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message:  "Be more original!")
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
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        getScore()
        newWord = ""
    }
    
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load File from Bundle")
    }
    
    func lessThanThreeWords(word: String) -> Bool {
        return word.count >= 3
    }
    
    func sameAsStartWord(word: String) -> Bool {
        return word != rootWord
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
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
