#!/usr/bin/env python3
"""Audio helper for the te reo app.

  python3 scripts/audio.py status     which words have a recording and which don't
  python3 scripts/audio.py checklist  write AUDIO-CHECKLIST.md (file names to record)
  python3 scripts/audio.py sync       copy audio/ into the iOS app's Audio folder

Put recordings in audio/ named <slug>.m4a (mp3, wav, aac and caf also work).
"""
import re, shutil, sys, unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXTS = (".m4a", ".mp3", ".wav", ".aac", ".caf")


def slug(text):
    s = unicodedata.normalize("NFD", text)
    s = "".join(c for c in s if not unicodedata.combining(c)).lower()
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")


def words():
    rows = re.findall(r'\{ reo: "(.*?)", en: "(.*?)", topic: "(.*?)"', (ROOT / "vocab.js").read_text())
    seen = {}
    for reo, en, topic in rows:
        s = slug(reo)
        if s in seen:
            sys.exit(f"Duplicate file name '{s}' for '{reo}' and '{seen[s]}'")
        seen[s] = reo
    return [(reo, en, topic, slug(reo)) for reo, en, topic in rows]


def recording(s):
    return next((p for e in EXTS if (p := ROOT / "audio" / f"{s}{e}").exists()), None)


def status():
    have = [w for w in words() if recording(w[3])]
    missing = [w for w in words() if not recording(w[3])]
    print(f"{len(have)}/{len(have) + len(missing)} words have recordings")
    for reo, en, topic, s in missing:
        print(f"  missing  {s:<24} {reo}")


def checklist():
    lines = ["# Audio checklist", "",
             "Record each word once, clearly. Save as the file name shown (.m4a is best).", "",
             "| Done | Word | Meaning | File name |", "|---|---|---|---|"]
    for reo, en, topic, s in words():
        lines.append(f"| {'x' if recording(s) else ' '} | {reo} | {en} | `{s}.m4a` |")
    (ROOT / "AUDIO-CHECKLIST.md").write_text("\n".join(lines) + "\n")
    print("Wrote AUDIO-CHECKLIST.md")


def sync():
    dest = ROOT / "ios" / "TeReo" / "Audio"
    dest.mkdir(parents=True, exist_ok=True)
    n = 0
    for p in (ROOT / "audio").iterdir():
        if p.suffix in EXTS:
            shutil.copy2(p, dest / p.name)
            n += 1
    print(f"Copied {n} recording(s) to ios/TeReo/Audio")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    {"status": status, "checklist": checklist, "sync": sync}.get(cmd, lambda: sys.exit(__doc__))()
