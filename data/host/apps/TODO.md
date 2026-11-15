# App Hub — 100 App TODO

Each row maps to a `.asx-app.json` in `data/host/apps/`.
Status: `[ ]` not started · `[~]` manifest drafted · `[x]` HTML shell + manifest done.

Hero phase key (K'UHUL C6):
- **Pop** — seed / intro / discovery surface
- **Wo**  — state / binding / profile surface
- **Yax** — candidate expansion / explore / browse
- **Sek** — transformation / dispatch / do-work surface
- **Ch'en** — observation / proof / review surface
- **Xul** — commit / publish / checkout surface

---

## Blogs & Content

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 1 | `blog` | Personal Blog | Pop | posts, comments, prefs | [~] |
| 2 | `newsletter` | Newsletter | Yax | issues, subscribers, prefs | [ ] |
| 3 | `portfolio` | Creative Portfolio | Pop | projects, testimonials, prefs | [~] |
| 4 | `docs-site` | Documentation Site | Yax | articles, versions, feedback | [ ] |
| 5 | `recipe-book` | Recipe Book | Pop | recipes, ingredients, reviews | [ ] |
| 6 | `book-club` | Book Club | Wo | books, members, notes | [ ] |
| 7 | `podcast` | Podcast Show | Sek | episodes, shownotes, subscribers | [ ] |
| 8 | `magazine` | Online Magazine | Ch'en | articles, editions, bylines | [ ] |
| 9 | `photo-journal` | Photo Journal | Pop | albums, photos, captions | [ ] |
| 10 | `travel-log` | Travel Log | Pop | trips, places, notes | [ ] |

### TODO per app (Blogs & Content)
- [ ] Add `@theme` block: choose accent/bg palette fitting the category
- [ ] Define `@data.spotlight`: 3 featured posts or items
- [ ] Wire `@extensions.@available`: comments (free), subscriber-list, newsletter-bot
- [ ] Add `hero_phase` to `@layout`
- [ ] Schema: `content-rows` for articles/posts, `visitor` prefs singleton
- [ ] HTML shell (optional, simplify via `asx-blocks` template)

---

## Social & Community

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 11 | `community-board` | Community Board | Wo | threads, replies, members | [ ] |
| 12 | `q-and-a` | Q & A | Ch'en | questions, answers, votes | [ ] |
| 13 | `events-board` | Events Board | Yax | events, rsvps, prefs | [ ] |
| 14 | `job-board` | Job Board | Sek | listings, applications, prefs | [ ] |
| 15 | `classifieds` | Local Classifieds | Yax | listings, contacts, prefs | [ ] |
| 16 | `review-app` | Reviews | Ch'en | items, reviews, ratings | [ ] |
| 17 | `group-chat` | Group Chat | Sek | rooms, messages, members | [ ] |
| 18 | `poll-app` | Polls | Yax | polls, options, votes | [ ] |
| 19 | `wishlist` | Shared Wishlist | Pop | wishes, claims, prefs | [ ] |
| 20 | `guestbook` | Guestbook | Xul | entries, view_count | [ ] |

### TODO per app (Social & Community)
- [ ] `@extensions`: moderation-bot, notification-hooks, reply-bots
- [ ] Shared tables (`@scope: "shared"`) for public votes, guestbook entries
- [ ] Visitor tables for RSVP, applications, contact forms
- [ ] `@data.suggestions`: seed content for preview
- [ ] Add `@assistant_patterns` for key actions (post, vote, RSVP)

---

## Commerce & Business

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 21 | `store` | Online Store | Yax | products, orders, reviews | [~] |
| 22 | `marketplace` | Marketplace | Sek | listings, bids, sellers | [ ] |
| 23 | `booking` | Service Booking | Sek | services, slots, bookings | [ ] |
| 24 | `invoicing` | Invoicing | Xul | invoices, line_items, clients | [ ] |
| 25 | `subscription-box` | Subscription Box | Xul | plans, subscribers, shipments | [ ] |
| 26 | `digital-downloads` | Digital Downloads | Sek | products, purchases, downloads | [ ] |
| 27 | `affiliate-links` | Affiliate Links Hub | Yax | links, clicks, earnings | [ ] |
| 28 | `price-tracker` | Price Tracker | Yax | products, prices, alerts | [ ] |
| 29 | `loyalty-points` | Loyalty Points | Xul | customers, points, redemptions | [ ] |
| 30 | `donations` | Donations / Tips | Xul | campaigns, donations, donors | [ ] |

### TODO per app (Commerce & Business)
- [ ] `@extensions`: stripe-payments (setup_required), product-spotlight (free), inventory-bot
- [ ] `@data.spotlight`: 3 featured products with price, image_url, badge
- [ ] Owner tables for catalog, visitor tables for cart/order submission
- [ ] `@theme`: commerce palette — warm amber + dark navy or clean white + green
- [ ] `hero_phase: "Yax"` for browse, `"Xul"` for checkout confirmation
- [ ] `@programs`: cart.add, cart.checkout, product.view

---

## Tools & Productivity

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 31 | `kanban` | Kanban Board | Sek | boards, cards, tags | [ ] |
| 32 | `notes` | Notes | Pop | notes, tags, prefs | [ ] |
| 33 | `time-tracker` | Time Tracker | Sek | sessions, projects, reports | [ ] |
| 34 | `habit-tracker` | Habit Tracker | Yax | habits, logs, streaks | [ ] |
| 35 | `goal-tracker` | Goal Tracker | Ch'en | goals, milestones, evidence | [ ] |
| 36 | `budget-tracker` | Budget Tracker | Xul | transactions, categories, budgets | [ ] |
| 37 | `todo-list` | Shared To-Do | Sek | tasks, assignments, prefs | [ ] |
| 38 | `reading-list` | Reading List | Yax | books, progress, notes | [ ] |
| 39 | `flashcards` | Flashcards | Yax | decks, cards, review_log | [ ] |
| 40 | `mood-journal` | Mood Journal | Pop | entries, moods, prefs | [ ] |

### TODO per app (Tools & Productivity)
- [ ] `@extensions`: export-csv (free), reminder-bot, streak-tracker
- [ ] Visitor-scoped tables (each user's own data — habit logs, budget rows)
- [ ] `@state`: current board/deck/session state
- [ ] `@programs`: item.create, item.complete, item.archive
- [ ] `hero_phase` determined by primary action: Sek for do-work, Yax for browse/plan

---

## Creative & Media

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 41 | `art-gallery` | Art Gallery | Pop | artworks, collections, sales | [ ] |
| 42 | `music-player` | Music Player | Sek | tracks, playlists, plays | [ ] |
| 43 | `video-channel` | Video Channel | Sek | videos, series, comments | [ ] |
| 44 | `writing-pad` | Writing Pad | Wo | documents, drafts, comments | [ ] |
| 45 | `code-snippets` | Code Snippets | Sek | snippets, tags, stars | [ ] |
| 46 | `design-showcase` | Design Showcase | Pop | designs, tools, credits | [ ] |
| 47 | `font-explorer` | Font Explorer | Yax | fonts, categories, favorites | [ ] |
| 48 | `color-palette` | Color Palette Builder | Pop | palettes, colors, exports | [ ] |
| 49 | `icon-library` | Icon Library | Yax | icons, packs, downloads | [ ] |
| 50 | `animation-lab` | Animation Lab | Sek | animations, code, previews | [ ] |

### TODO per app (Creative & Media)
- [ ] `@data.spotlight`: 3 featured works with thumbnail, title, medium
- [ ] `@theme`: expressive palette (purples for creative, dark + neon for code)
- [ ] `@extensions`: print-on-demand, license-generator, collab-invite
- [ ] Download / star counters as `@scope: "shared"` counter tables

---

## Health & Fitness

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 51 | `workout-log` | Workout Log | Sek | workouts, sets, prefs | [ ] |
| 52 | `meal-planner` | Meal Planner | Yax | meals, ingredients, shopping | [ ] |
| 53 | `water-tracker` | Water Tracker | Pop | logs, prefs | [ ] |
| 54 | `sleep-log` | Sleep Log | Pop | entries, prefs | [ ] |
| 55 | `weight-log` | Weight Log | Ch'en | entries, goals, prefs | [ ] |
| 56 | `meditation-timer` | Meditation Timer | Pop | sessions, prefs | [ ] |
| 57 | `symptom-log` | Symptom Log | Ch'en | entries, severity, prefs | [ ] |
| 58 | `running-log` | Running Log | Sek | runs, routes, prefs | [ ] |
| 59 | `nutrition-db` | Nutrition Database | Ch'en | foods, logs, goals | [ ] |
| 60 | `wellness-check` | Daily Wellness Check-in | Pop | entries, streaks, prefs | [ ] |

### TODO per app (Health & Fitness)
- [ ] All data visitor-scoped (private health records per user)
- [ ] `@permissions.storage: "request_scoped"` + no network
- [ ] `@extensions`: goal-bot, progress-chart, export-pdf
- [ ] `@data.hero_phase: "Pop"` for intro/seed surfaces

---

## Education & Learning

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 61 | `quiz-builder` | Quiz Builder | Yax | quizzes, questions, results | [ ] |
| 62 | `online-course` | Online Course | Sek | lessons, progress, certificates | [ ] |
| 63 | `homework-hub` | Homework Hub | Wo | assignments, submissions, grades | [ ] |
| 64 | `math-drills` | Math Drills | Yax | problems, attempts, scores | [ ] |
| 65 | `language-cards` | Language Cards | Yax | decks, cards, review_log | [ ] |
| 66 | `science-lab` | Science Lab | Ch'en | experiments, observations, results | [ ] |
| 67 | `coding-challenge` | Coding Challenges | Sek | challenges, solutions, scores | [ ] |
| 68 | `tutor-scheduler` | Tutor Scheduler | Sek | tutors, sessions, bookings | [ ] |
| 69 | `gradebook` | Gradebook | Ch'en | students, grades, reports | [ ] |
| 70 | `debate-club` | Debate Club | Ch'en | topics, arguments, votes | [ ] |

### TODO per app (Education & Learning)
- [ ] Owner table for curriculum, visitor table for progress/submissions
- [ ] `@extensions`: certificate-generator, leaderboard (shared), study-bot
- [ ] `@assistant_patterns`: START QUIZ *, SUBMIT ANSWER *, CHECK GRADE *

---

## Local & Community

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 71 | `neighborhood` | Neighborhood Board | Wo | posts, announcements, members | [ ] |
| 72 | `pet-care` | Pet Care Records | Pop | pets, records, prefs | [ ] |
| 73 | `plant-care` | Plant Care Tracker | Pop | plants, logs, prefs | [ ] |
| 74 | `volunteer` | Volunteer Coordinator | Sek | opportunities, sign_ups, hours | [ ] |
| 75 | `lost-found` | Lost & Found | Yax | items, claims, prefs | [ ] |
| 76 | `local-map` | Local Business Map | Yax | businesses, reviews, prefs | [ ] |
| 77 | `car-pool` | Carpool Organizer | Sek | rides, passengers, prefs | [ ] |
| 78 | `garden-log` | Garden Journal | Pop | plants, logs, harvests | [ ] |
| 79 | `tool-lending` | Tool Lending Library | Wo | tools, loans, queue | [ ] |
| 80 | `emergency-plan` | Family Emergency Plan | Ch'en | contacts, plans, resources | [ ] |

### TODO per app (Local & Community)
- [ ] Mix of owner (catalog), visitor (log/signup), shared (board posts)
- [ ] `@theme`: earthy greens for nature apps, civic blues for community
- [ ] `@extensions`: notification-hooks, moderation-bot, map-widget

---

## Games & Fun

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 81 | `trivia` | Trivia Game | Yax | questions, scores, leaderboard | [ ] |
| 82 | `word-game` | Word Puzzle | Sek | puzzles, attempts, scores | [ ] |
| 83 | `scoreboard` | Scoreboard | Xul | games, scores, players | [ ] |
| 84 | `rpg-character` | RPG Character Sheet | Sek | characters, items, logs | [ ] |
| 85 | `tournament` | Tournament Bracket | Ch'en | players, matches, results | [ ] |
| 86 | `bingo` | Bingo Card Generator | Yax | cards, calls, games | [ ] |
| 87 | `dice-roller` | Dice Roller | Pop | sessions, results | [ ] |
| 88 | `countdown` | Event Countdown | Pop | events, prefs | [ ] |
| 89 | `random-picker` | Random Picker | Yax | lists, picks, history | [ ] |
| 90 | `reaction-game` | Reaction Time Game | Sek | sessions, scores, prefs | [ ] |

### TODO per app (Games & Fun)
- [ ] Shared leaderboard tables (`@scope: "shared"`)
- [ ] `@extensions`: multiplayer-bot, score-tweet, replay-log
- [ ] `@theme`: vibrant/neon palette — electric blue + gold for games

---

## Niche & Special Interest

| # | App ID | Title | Hero Phase | Tables | Status |
|---|--------|-------|-----------|--------|--------|
| 91 | `wine-log` | Wine Tasting Journal | Ch'en | bottles, tastings, cellars | [ ] |
| 92 | `chess-log` | Chess Game Log | Ch'en | games, moves, analysis | [ ] |
| 93 | `genealogy` | Family Tree | Wo | people, relations, records | [ ] |
| 94 | `star-map` | Astronomy Log | Pop | observations, objects, prefs | [ ] |
| 95 | `bird-watch` | Bird Watching Log | Pop | sightings, species, locations | [ ] |
| 96 | `coin-collect` | Coin Collection | Yax | coins, sets, valuations | [ ] |
| 97 | `movie-tracker` | Movie Watchlist | Yax | movies, reviews, prefs | [ ] |
| 98 | `car-mods` | Car Mods Log | Sek | vehicles, mods, costs | [ ] |
| 99 | `aquarium-log` | Aquarium Diary | Pop | tanks, species, logs | [ ] |
| 100 | `diy-projects` | DIY Projects | Sek | projects, steps, materials | [ ] |

### TODO per app (Niche & Special Interest)
- [ ] `@data.spotlight`: 3 seed items fitting the niche (bottles, species, coins)
- [ ] `@theme`: domain-specific palette (wine=deep burgundy, astronomy=midnight navy)
- [ ] `@extensions`: export-pdf, barcode-scanner, share-collection

---

## Cross-cutting tasks

- [ ] Register all 100 apps in `registry.json` under `kits[]` (category: their domain)
- [ ] Add all 100 to the App Hub catalog grid (`app-hub.html` `APP_CATALOG` array)
- [ ] Wire `@assistant_patterns` AIML entries in `khanary-distilled.aiml` for the 10 most common verbs (OPEN, BROWSE, ADD, CREATE, EDIT, DELETE, SEARCH, EXPORT, SHARE, RESET)
- [ ] Conformance: run `py -3 tools/check_app_tables.py` after adding new table schemas
- [ ] Vite variants: for apps 31/32/34/39/61/65 create `data/templates/vite-react-ts/` slot fills
- [ ] Phase audit: verify `hero_phase` is consistent with the dominant `@programs` authority phase

---

## Hero phase reference card

```
Pop   → discovery, intro hero, first-load state, brand introduction
Wo    → profile, settings, binding surface, member home
Yax   → explore, search, browse, candidate grid
Sek   → do-work, compose, edit, run, dispatch
Ch'en → review, verify, audit, prove, confirm
Xul   → checkout, publish, commit, send, finalize
```

Each app's `@theme.hero_phase` matches the first meaningful user action:
- A store's hero = browse (Yax); its checkout = Xul
- A blog's hero = read/discover (Pop); its compose panel = Sek
- A booking app's hero = pick a slot (Sek); confirmation = Xul
