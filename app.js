const $ = (id) => document.getElementById(id);

// ---- Storage -------------------------------------------------------------
// progress: { [reo]: { box, due } }   days: ["YYYY-MM-DD", ...] days practised
const KEY = "te-reo-app/v1";
const DAY = 86400000;
const INTERVALS = [0, DAY, 3 * DAY, 7 * DAY, 21 * DAY]; // wait before each box is due again
const LEARNED_BOX = 3;

let saved = { progress: {}, days: [] };
try { saved = { ...saved, ...JSON.parse(localStorage.getItem(KEY)) }; } catch {}
const persist = () => { try { localStorage.setItem(KEY, JSON.stringify(saved)); } catch {} };

const today = () => { const d = new Date(); return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`; };

function recordAnswer(word, correct) {
  const p = saved.progress[word.reo] || { box: 0, due: 0 };
  p.box = correct ? Math.min(p.box + 1, INTERVALS.length - 1) : 0;
  p.due = Date.now() + INTERVALS[p.box];
  saved.progress[word.reo] = p;
  if (!saved.days.includes(today())) saved.days.push(today());
  persist();
}

function streak() {
  const set = new Set(saved.days);
  const d = new Date();
  if (!set.has(today())) d.setDate(d.getDate() - 1); // today not practised yet: streak still alive
  let n = 0;
  for (;;) {
    const k = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
    if (!set.has(k)) return n;
    n++;
    d.setDate(d.getDate() - 1);
  }
}

// ---- Audio ---------------------------------------------------------------
// File name for a word's recording, e.g. "Tēnā koe" -> "tena-koe". Matches scripts/audio.py.
const slug = (t) => t.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

function speakWithVoice(word) {
  if (!("speechSynthesis" in window)) return;
  const u = new SpeechSynthesisUtterance(word.reo.replace("___", ""));
  u.lang = "mi-NZ";
  u.rate = 0.8;
  speechSynthesis.cancel();
  speechSynthesis.speak(u);
}

// Plays audio/<slug>.m4a if it exists, otherwise falls back to the browser voice.
function speak(word) {
  const audio = new Audio(word.audio || `audio/${slug(word.reo)}.m4a`);
  audio.onerror = () => speakWithVoice(word);
  audio.play().catch(() => speakWithVoice(word));
}

// ---- Study ---------------------------------------------------------------
const state = { mode: "flash", topic: "All", deck: [], current: null, flipped: false, right: 0, seen: 0, anyway: false };

const shuffle = (a) => a.map((x) => [Math.random(), x]).sort((p, q) => p[0] - q[0]).map((p) => p[1]);
const inTopic = (v) => state.topic === "All" || v.topic === state.topic;
const isDue = (v) => (saved.progress[v.reo]?.due ?? 0) <= Date.now();
const dueCount = () => VOCAB.filter((v) => inTopic(v) && isDue(v)).length;

function loadDeck() {
  const pool = VOCAB.filter((v) => inTopic(v) && (state.anyway || isDue(v)));
  // lowest box first so the weakest words come up soonest; shuffle within a box
  state.deck = shuffle(pool).sort((a, b) => (saved.progress[b.reo]?.box ?? 0) - (saved.progress[a.reo]?.box ?? 0));
}

function nextWord() {
  if (!state.deck.length) loadDeck();
  const empty = !state.deck.length;
  $("done").hidden = !empty;
  $("flash").hidden = empty || state.mode !== "flash";
  $("quiz").hidden = empty || state.mode !== "quiz";
  $("due").textContent = `${dueCount()} due now`;
  if (empty) return;
  state.current = state.deck.pop();
  state.flipped = false;
  state.mode === "flash" ? showCard() : showQuiz();
}

function showCard() {
  const card = $("card");
  card.textContent = state.flipped ? state.current.en : state.current.reo;
  card.classList.toggle("back", state.flipped);
}

function showQuiz() {
  const word = state.current;
  const others = VOCAB.filter((v) => v.en !== word.en);
  const sameTopic = shuffle(others.filter((v) => v.topic === word.topic));
  const rest = shuffle(others.filter((v) => v.topic !== word.topic));
  const wrong = [...sameTopic, ...rest].slice(0, 3);
  $("prompt").textContent = word.reo;
  $("feedback").textContent = "";
  $("next").hidden = true;
  $("choices").replaceChildren(
    ...shuffle([word, ...wrong]).map((opt) => {
      const b = document.createElement("button");
      b.type = "button";
      b.textContent = opt.en;
      b.onclick = () => answer(b, opt === word);
      return b;
    })
  );
}

function answer(btn, correct) {
  state.seen++;
  if (correct) state.right++;
  recordAnswer(state.current, correct);
  for (const b of $("choices").children) {
    b.disabled = true;
    if (b.textContent === state.current.en) b.classList.add("right");
  }
  if (!correct) btn.classList.add("wrong");
  $("feedback").textContent = correct ? "Kei te tika! (Correct)" : "Not quite";
  $("next").hidden = false;
  updateScore();
}

function grade(correct) {
  state.seen++;
  if (correct) state.right++;
  recordAnswer(state.current, correct);
  updateScore();
  nextWord();
}

function updateScore() {
  $("score").textContent = state.seen ? `${state.right}/${state.seen}` : "";
}

function setMode(mode) {
  state.mode = mode;
  $("mode").textContent = mode === "flash" ? "Switch to quiz" : "Switch to flashcards";
  nextWord();
}

function resetDeck() { state.deck = []; state.anyway = false; nextWord(); }

// ---- Progress ------------------------------------------------------------
function renderProgress() {
  const learned = VOCAB.filter((v) => (saved.progress[v.reo]?.box ?? 0) >= LEARNED_BOX).length;
  const started = VOCAB.filter((v) => saved.progress[v.reo]).length;
  const stats = [
    [learned, "words learned"],
    [started, "words started"],
    [VOCAB.filter(isDue).length, "due now"],
    [streak(), "day streak"],
  ];
  $("stats").replaceChildren(...stats.map(([n, label]) => {
    const d = document.createElement("div");
    d.className = "stat";
    d.innerHTML = `<b>${n}</b><span>${label}</span>`;
    return d;
  }));
  $("topics").replaceChildren(...[...new Set(VOCAB.map((v) => v.topic))].map((t) => {
    const words = VOCAB.filter((v) => v.topic === t);
    const done = words.filter((v) => (saved.progress[v.reo]?.box ?? 0) >= LEARNED_BOX).length;
    const row = document.createElement("div");
    row.className = "topic-row";
    row.innerHTML = `${t} — ${done}/${words.length}<div class="meter"><i style="width:${(done / words.length) * 100}%"></i></div>`;
    return row;
  }));
}

function showTab(name) {
  $("study").hidden = name !== "study";
  $("progress").hidden = name !== "progress";
  $("tab-study").classList.toggle("active", name === "study");
  $("tab-progress").classList.toggle("active", name === "progress");
  if (name === "progress") renderProgress(); else resetDeck();
}

// ---- Init ----------------------------------------------------------------
function init() {
  const topics = ["All", ...new Set(VOCAB.map((v) => v.topic))];
  $("topic").replaceChildren(...topics.map((t) => new Option(t, t)));
  $("topic").onchange = (e) => { state.topic = e.target.value; resetDeck(); };
  $("mode").onclick = () => setMode(state.mode === "flash" ? "quiz" : "flash");
  $("card").onclick = () => { state.flipped = !state.flipped; showCard(); };
  $("again").onclick = () => grade(false);
  $("got").onclick = () => grade(true);
  $("next").onclick = nextWord;
  $("speak").onclick = () => state.current && speak(state.current);
  $("speak2").onclick = () => state.current && speak(state.current);
  $("practice").onclick = () => { state.anyway = true; state.deck = []; nextWord(); };
  $("tab-study").onclick = () => showTab("study");
  $("tab-progress").onclick = () => showTab("progress");
  $("reset").onclick = () => {
    if (!confirm("Erase all progress?")) return;
    saved = { progress: {}, days: [] };
    persist();
    renderProgress();
  };
  setMode("flash");
}

init();

if ("serviceWorker" in navigator) navigator.serviceWorker.register("sw.js").catch(() => {});
