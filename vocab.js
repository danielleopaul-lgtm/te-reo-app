// Vocabulary. Each entry: { reo, en, topic, audio? }
// `audio` is an optional path to a real recording (e.g. "audio/kia-ora.mp3");
// without it the app falls back to the browser's text-to-speech.
const VOCAB = [
  // Greetings
  { reo: "Kia ora", en: "Hello / thanks", topic: "Greetings" },
  { reo: "Mōrena", en: "Good morning", topic: "Greetings" },
  { reo: "Tēnā koe", en: "Hello (to one person)", topic: "Greetings" },
  { reo: "Tēnā koutou", en: "Hello (to three or more people)", topic: "Greetings" },
  { reo: "Haere mai", en: "Welcome (come here)", topic: "Greetings" },
  { reo: "Haere rā", en: "Goodbye (to one leaving)", topic: "Greetings" },
  { reo: "E noho rā", en: "Goodbye (to one staying)", topic: "Greetings" },
  { reo: "Ka kite anō", en: "See you again", topic: "Greetings" },
  { reo: "Kia kaha", en: "Be strong", topic: "Greetings" },
  { reo: "Ngā mihi", en: "Thanks / best wishes", topic: "Greetings" },

  // Everyday
  { reo: "Whānau", en: "Family", topic: "Everyday" },
  { reo: "Tamariki", en: "Children", topic: "Everyday" },
  { reo: "Kai", en: "Food", topic: "Everyday" },
  { reo: "Wai", en: "Water", topic: "Everyday" },
  { reo: "Whare", en: "House", topic: "Everyday" },
  { reo: "Kura", en: "School", topic: "Everyday" },
  { reo: "Pukapuka", en: "Book", topic: "Everyday" },
  { reo: "Aroha", en: "Love", topic: "Everyday" },
  { reo: "Āe", en: "Yes", topic: "Everyday" },
  { reo: "Kāo", en: "No", topic: "Everyday" },

  // Numbers
  { reo: "Tahi", en: "One", topic: "Numbers" },
  { reo: "Rua", en: "Two", topic: "Numbers" },
  { reo: "Toru", en: "Three", topic: "Numbers" },
  { reo: "Whā", en: "Four", topic: "Numbers" },
  { reo: "Rima", en: "Five", topic: "Numbers" },
  { reo: "Ono", en: "Six", topic: "Numbers" },
  { reo: "Whitu", en: "Seven", topic: "Numbers" },
  { reo: "Waru", en: "Eight", topic: "Numbers" },
  { reo: "Iwa", en: "Nine", topic: "Numbers" },
  { reo: "Tekau", en: "Ten", topic: "Numbers" },

  // Colours
  { reo: "Whero", en: "Red", topic: "Colours" },
  { reo: "Karaka", en: "Orange", topic: "Colours" },
  { reo: "Kōwhai", en: "Yellow", topic: "Colours" },
  { reo: "Kākāriki", en: "Green", topic: "Colours" },
  { reo: "Kikorangi", en: "Blue", topic: "Colours" },
  { reo: "Waiporoporo", en: "Purple", topic: "Colours" },
  { reo: "Mawhero", en: "Pink", topic: "Colours" },
  { reo: "Parauri", en: "Brown", topic: "Colours" },
  { reo: "Pango", en: "Black", topic: "Colours" },
  { reo: "Mā", en: "White", topic: "Colours" },

  // People
  { reo: "Māmā", en: "Mother", topic: "People" },
  { reo: "Pāpā", en: "Father", topic: "People" },
  { reo: "Tāne", en: "Man", topic: "People" },
  { reo: "Wahine", en: "Woman", topic: "People" },
  { reo: "Tama", en: "Boy / son", topic: "People" },
  { reo: "Tamāhine", en: "Daughter", topic: "People" },
  { reo: "Kuia", en: "Elderly woman", topic: "People" },
  { reo: "Koroua", en: "Elderly man", topic: "People" },
  { reo: "Tuakana", en: "Older sibling (of same gender)", topic: "People" },
  { reo: "Teina", en: "Younger sibling (of same gender)", topic: "People" },

  // Phrases
  { reo: "Kei te pēhea koe?", en: "How are you?", topic: "Phrases" },
  { reo: "Kei te pai", en: "I'm good", topic: "Phrases" },
  { reo: "Ko wai tō ingoa?", en: "What is your name?", topic: "Phrases" },
  { reo: "Ko ___ tōku ingoa", en: "My name is ___", topic: "Phrases" },
  { reo: "Ka pai", en: "Good / well done", topic: "Phrases" },
  { reo: "Ngā mihi nui", en: "Thank you very much", topic: "Phrases" },
  { reo: "Nau mai", en: "Welcome (to a place)", topic: "Phrases" },
  { reo: "Kei te mōhio au", en: "I know", topic: "Phrases" },
  { reo: "Kāore au i te mōhio", en: "I don't know", topic: "Phrases" },
  { reo: "Tēnā koa", en: "Please", topic: "Phrases" },
];
