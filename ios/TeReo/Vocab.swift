import Foundation

struct Word: Identifiable, Hashable {
    let reo: String
    let en: String
    let topic: String
    var id: String { reo }
}

// Generated from the web app's vocab.js. Add words here.
let vocabulary: [Word] = [
    Word(reo: "Kia ora", en: "Hello / thanks", topic: "Greetings"),
    Word(reo: "Mōrena", en: "Good morning", topic: "Greetings"),
    Word(reo: "Tēnā koe", en: "Hello (to one person)", topic: "Greetings"),
    Word(reo: "Tēnā koutou", en: "Hello (to three or more people)", topic: "Greetings"),
    Word(reo: "Haere mai", en: "Welcome (come here)", topic: "Greetings"),
    Word(reo: "Haere rā", en: "Goodbye (to one leaving)", topic: "Greetings"),
    Word(reo: "E noho rā", en: "Goodbye (to one staying)", topic: "Greetings"),
    Word(reo: "Ka kite anō", en: "See you again", topic: "Greetings"),
    Word(reo: "Kia kaha", en: "Be strong", topic: "Greetings"),
    Word(reo: "Ngā mihi", en: "Thanks / best wishes", topic: "Greetings"),
    Word(reo: "Whānau", en: "Family", topic: "Everyday"),
    Word(reo: "Tamariki", en: "Children", topic: "Everyday"),
    Word(reo: "Kai", en: "Food", topic: "Everyday"),
    Word(reo: "Wai", en: "Water", topic: "Everyday"),
    Word(reo: "Whare", en: "House", topic: "Everyday"),
    Word(reo: "Kura", en: "School", topic: "Everyday"),
    Word(reo: "Pukapuka", en: "Book", topic: "Everyday"),
    Word(reo: "Aroha", en: "Love", topic: "Everyday"),
    Word(reo: "Āe", en: "Yes", topic: "Everyday"),
    Word(reo: "Kāo", en: "No", topic: "Everyday"),
    Word(reo: "Tahi", en: "One", topic: "Numbers"),
    Word(reo: "Rua", en: "Two", topic: "Numbers"),
    Word(reo: "Toru", en: "Three", topic: "Numbers"),
    Word(reo: "Whā", en: "Four", topic: "Numbers"),
    Word(reo: "Rima", en: "Five", topic: "Numbers"),
    Word(reo: "Ono", en: "Six", topic: "Numbers"),
    Word(reo: "Whitu", en: "Seven", topic: "Numbers"),
    Word(reo: "Waru", en: "Eight", topic: "Numbers"),
    Word(reo: "Iwa", en: "Nine", topic: "Numbers"),
    Word(reo: "Tekau", en: "Ten", topic: "Numbers"),
    Word(reo: "Whero", en: "Red", topic: "Colours"),
    Word(reo: "Karaka", en: "Orange", topic: "Colours"),
    Word(reo: "Kōwhai", en: "Yellow", topic: "Colours"),
    Word(reo: "Kākāriki", en: "Green", topic: "Colours"),
    Word(reo: "Kikorangi", en: "Blue", topic: "Colours"),
    Word(reo: "Waiporoporo", en: "Purple", topic: "Colours"),
    Word(reo: "Mawhero", en: "Pink", topic: "Colours"),
    Word(reo: "Parauri", en: "Brown", topic: "Colours"),
    Word(reo: "Pango", en: "Black", topic: "Colours"),
    Word(reo: "Mā", en: "White", topic: "Colours"),
    Word(reo: "Māmā", en: "Mother", topic: "People"),
    Word(reo: "Pāpā", en: "Father", topic: "People"),
    Word(reo: "Tāne", en: "Man", topic: "People"),
    Word(reo: "Wahine", en: "Woman", topic: "People"),
    Word(reo: "Tama", en: "Boy / son", topic: "People"),
    Word(reo: "Tamāhine", en: "Daughter", topic: "People"),
    Word(reo: "Kuia", en: "Elderly woman", topic: "People"),
    Word(reo: "Koroua", en: "Elderly man", topic: "People"),
    Word(reo: "Tuakana", en: "Older sibling (of same gender)", topic: "People"),
    Word(reo: "Teina", en: "Younger sibling (of same gender)", topic: "People"),
    Word(reo: "Kei te pēhea koe?", en: "How are you?", topic: "Phrases"),
    Word(reo: "Kei te pai", en: "I'm good", topic: "Phrases"),
    Word(reo: "Ko wai tō ingoa?", en: "What is your name?", topic: "Phrases"),
    Word(reo: "Ko ___ tōku ingoa", en: "My name is ___", topic: "Phrases"),
    Word(reo: "Ka pai", en: "Good / well done", topic: "Phrases"),
    Word(reo: "Ngā mihi nui", en: "Thank you very much", topic: "Phrases"),
    Word(reo: "Nau mai", en: "Welcome (to a place)", topic: "Phrases"),
    Word(reo: "Kei te mōhio au", en: "I know", topic: "Phrases"),
    Word(reo: "Kāore au i te mōhio", en: "I don't know", topic: "Phrases"),
    Word(reo: "Tēnā koa", en: "Please", topic: "Phrases"),
]

let topics: [String] = {
    var seen: [String] = []
    for w in vocabulary where !seen.contains(w.topic) { seen.append(w.topic) }
    return seen
}()
