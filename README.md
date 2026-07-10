# wfl-web

**The WFL website — written in WFL, powered by Scriptorium.**

This is the marketing + docs site for [WFL, the WebFirst Language](https://github.com/WebFirstLanguage/wfl),
and it is written in WFL end to end. It runs on the
[Scriptorium](https://github.com/WebFirstLanguage/scriptorium) CMS engine
(vendored into this repo): one WFL web server opens a SQLite database, serves the
public site, and hosts a login-protected `/admin` panel. Pages are rendered with
the [Scribe](https://github.com/WebFirstLanguage/scribe) templating engine, code
samples are colored by a WFL-native syntax highlighter, and the whole thing wears
the **WFL Design System** (dark, teal-on-Ink).

> Programming that reads like plain English — including the program that serves
> this page, stores its News posts, and runs its playground.

## Run it

You need the `wfl` CLI ([build it](https://github.com/WebFirstLanguage/wfl) with
`cargo build --release`). Then, **from the repository root** (template and asset
paths resolve relative to the working directory):

```sh
wfl main.wfl          # or: scripts/run.sh
```

On first run it creates `scriptorium.db`, seeds default settings, prints a
**one-time admin password**, and seeds a few launch **News** posts:

```text
==================================================
 wfl-web — first run: seeded an admin account
   username:  admin
   password:  <generated-password>   # a fresh random value is printed here
   (shown once — sign in at /admin and add users under Users)
==================================================
wfl-web — seeded 3 launch News posts.
wfl-web (powered by Scriptorium) is running at http://127.0.0.1:8080  (admin: /admin)
```

Open <http://127.0.0.1:8080/> for the site and <http://127.0.0.1:8080/admin> to
sign in. Bind address, TLS, and the body-size cap live in `.wflcfg`; the server
listens on `127.0.0.1:8080` by default (set `web_server_bind_address = 0.0.0.0`
to expose it behind a reverse proxy).

## How the site is put together

The site is a **hybrid**: rich, hand-authored pages for the marketing/docs
surface, and genuine CMS content for anything that changes over time.

- **Rich pages are HTML, not markdown**, so they stay custom routes rendered from
  this repo's own templates via `lib/site.wfl` and `lib/playground.wfl`: the
  landing page (hero, language compare, feature grid, error showcase), the
  getting-started docs page, the live playground, and the 404.
- **The News section is Scriptorium CMS content** — SQLite-backed posts, authored
  and edited in `/admin`, served at `/news` and `/post/:slug`. It's the same
  blog engine Scriptorium ships; here it powers project announcements.

Both surfaces render through the **same** `templates/base.html`, so News and the
marketing pages share one nav, footer, and design system — they never look like
two different sites.

## Routes

| Method | Path | What |
| --- | --- | --- |
| GET | `/` | Landing page (hero, compare, features, errors, install) |
| GET | `/getting-started` | Getting-started docs |
| GET/POST | `/playground` | The live playground (see below); POST runs a tool |
| GET | `/news` · `/news/page/:n` | News feed (paginated) |
| GET | `/post/:slug` | A published News post |
| GET | `/page/:slug` | A published CMS page |
| GET | `/assets/*` | Static files (design system, uploads) → `static/` |
| GET/POST | `/admin/login` · `/admin/logout` | Auth |
| GET | `/admin` | Dashboard |
| GET/POST | `/admin/posts…` · `/admin/pages…` · `/admin/media…` | Content CRUD |
| GET/POST | `/admin/users…` · `/admin/settings` | Users & settings *(admin only)* |
| — | (any miss) | Rich 404 |

Every admin POST carries the session's CSRF token; the public playground POST is
outside that gate (it's a public form, not an admin action).

## The playground — WFL flexing on itself

`/playground` is a page *about* WFL that is *running* WFL on every request:

- **Three real programs execute on each load.** `playground/examples/*.wfl`
  (FizzBuzz, Fibonacci, primes) are read, highlighted, and run with
  `execute wfl file … and read output` — the output you see is whatever the
  program just displayed, computed at request time. A broken example can't take
  the server down; `execute wfl file` turns its error into a catchable one.
- **Interactive tools compute on your input**, server-side, with the standard
  library: **WFLHASH-256 + SHA-256** (crypto), **text stats** (length, words,
  uppercase, reverse), and **email validation** with the readable pattern engine.
  You submit a form; WFL parses it (`parse_form_urlencoded`), computes, and
  re-renders the page with the answer.

## How it loads — one include spine

The whole app loads through a single `include` in `main.wfl`. WFL analyses each
included file against the scope that exists when it is included, and rejects a
call to an action an *earlier* include already executed — so the modules form one
linear spine, each pulling in its own dependencies exactly once (no shared
dependency is included from two branches, which WFL would treat as a
redefinition):

```
main.wfl
└─ lib/playground.wfl          # live playground: run examples + compute on input
   └─ lib/site.wfl             # marketing content, routing, code samples
      ├─ app/render.wfl        # Scriptorium engine …
      │  ├─ auth.wfl           #   sessions, CSRF, roles
      │  │  └─ db.wfl          #   SQLite schema + queries
      │  │     └─ util.wfl     #   slugify, to_int, field_or, …
      │  └─ lib/scribe.wfl     #   Scribe templating engine (vendored)
      ├─ lib/highlight.wfl     # WFL → highlighted HTML
      └─ lib/icons.wfl         # inline Lucide-style SVG icons
```

The templates use Scribe's Twig-style syntax: `{% extends %}` / `{% block %}`
inheritance from `templates/base.html`, `{% include %}` for the nav and footer
partials, `{% for %}` loops, the `markdown` filter for post/page bodies, and
`{{ value | raw }}` to emit trusted, pre-highlighted code HTML.

> **Note.** WFL's static checker prints non-fatal `Undefined action …` /
> `could not infer type` notes to stderr for cross-file calls resolved at
> runtime. The program still runs and serves — this is expected.

## Editing the site

- **Marketing copy & structure** — `templates/index.html`,
  `templates/getting-started.html`, `templates/404.html`, and the shared shell
  `templates/base.html` + `templates/partials/{nav,footer}.html`. Nav links,
  feature cards, footer columns, and code samples are plain WFL maps/lists in
  `lib/site.wfl`.
- **News** — write and edit posts in `/admin/posts`. The feed and article
  templates are `templates/news_index.html` and `templates/news_post.html`;
  standalone CMS pages use `templates/cms_page.html`.
- **Design tokens** (colors, type, spacing, effects, syntax) — under
  `static/ds/` (taken verbatim from the WFL Design System). Site-specific layout
  and the component ports (buttons, cards, callouts, badges, code blocks) live in
  `static/site.css`; admin styling in `static/admin.css`. Every value references
  a design-system token.

## Design system

The brand is dark, teal-on-Ink, code-forward.

| Token | Value | Role |
| --- | --- | --- |
| Ink | `#10221F` | background (`--surface-base`) |
| Mist | `#F5FAF8` | text (`--text-primary`) |
| Verdant Teal | `#12A594` | primary accent (`--accent`) |
| Deep Teal | `#0B7A6E` | pressed accent |
| Warm Amber | `#F2A73B` | highlight + code strings |

Type: **Alegreya** (display serif, self-hosted), **Hanken Grotesk** (body/UI),
**JetBrains Mono** (code). The logo mark (`static/ds/assets/wfl-mark.svg`) is an
outlined teal speech bubble with a chevron prompt and a leaf cursor.

## Layout

```
wfl-web/
├── main.wfl                  # boot (DB open, migrate, seed) + request loop + router
├── .wflcfg                   # WFL runtime config (bind address, TLS, body-size cap)
├── app/                      # Scriptorium engine (vendored)
│   ├── util.wfl · db.wfl · auth.wfl · render.wfl
├── lib/
│   ├── site.wfl              # marketing content, routing, code samples
│   ├── playground.wfl        # live playground: run examples + compute on input
│   ├── scribe.wfl            # Scribe templating engine (vendored)
│   ├── highlight.wfl         # WFL-native syntax highlighter
│   └── icons.wfl             # inline SVG icon set
├── playground/examples/      # real .wfl programs the server runs live
│   └── fizzbuzz.wfl · fibonacci.wfl · primes.wfl
├── templates/                # public site (rendered through base.html)
│   ├── base.html · index.html · getting-started.html · playground.html · 404.html
│   ├── news_index.html · news_post.html · cms_page.html
│   └── partials/{nav,footer}.html
├── admin/templates/          # admin panel (Scriptorium)
├── static/                   # served at /assets/*
│   ├── ds/                   # WFL Design System: tokens, fonts, logo
│   ├── site.css · admin.css  # site + admin styling
│   └── uploads/              # uploaded media (runtime)
├── TestPrograms/             # engine test suites (wfl --test)
└── scripts/run.sh
```

## Tests

```sh
wfl --test TestPrograms/util.test.wfl   # helpers (slugify, file_ext, parsing, …)
wfl --test TestPrograms/db.test.wfl     # data layer against sqlite::memory:
wfl --test TestPrograms/auth.test.wfl   # sessions + CSRF token checks
```

## License

Apache-2.0. See [LICENSE](LICENSE). WFL, the Scriptorium engine, and the Scribe
engine are Apache-2.0; the WFL Design System and brand assets are © Logbie LLC.
