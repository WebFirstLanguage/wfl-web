# wfl-web

**The WFL website — written in WFL.**

This is the marketing + docs site for [WFL, the WebFirst Language](https://github.com/WebFirstLanguage/wfl),
and it is written in WFL. The pipeline is WFL end to end: WFL data, the
[Scribe](https://github.com/WebFirstLanguage/scribe) templating engine (itself
written in WFL), and a WFL-native syntax highlighter that colors the site's own
code samples. The visual language — colors, type, spacing, the logo — comes
straight from the **WFL Design System**.

> Programming that reads like plain English — including the program that serves
> this page.

## Two ways to run it

The pages, data, and routing live in one shared module (`lib/site.wfl`), so the
same site renders either way — they never drift:

| | Command | What it does |
| --- | --- | --- |
| **Static** | `wfl build.wfl` | Renders every page once and writes `public/*.html`. Deploy the `public/` folder anywhere (GitHub Pages, Netlify, any static host). |
| **Live** | `wfl serve.wfl` | Starts a WFL web server on `:8080` and renders each page **on every request** — like PHP, but in plain-English WFL. Assets stream from `public/assets`. |

**Which should you use?** For a site whose content doesn't change per visitor,
**static** is best — nothing runs at request time and any CDN can cache it. Go
**live** when a page needs per-request data: query strings, form posts, sessions
or auth, a database, the current time, or anything personalized. (For a busy live
site you'd render each page once at startup into memory and re-render only when
the underlying data changes — the structure is already here to add that.)

## What's here

| Page | Route | Source template | Static output |
| --- | --- | --- | --- |
| Landing (hero, compare, features, errors, install) | `/` | `templates/index.html` | `public/index.html` |
| Getting started (docs) | `/getting-started` | `templates/getting-started.html` | `public/getting-started.html` |
| Not found | (any miss) | `templates/404.html` | `public/404.html` |

## How it's built

```
lib/site.wfl                       # the shared model: content, routing, rendering
 ├─ include scribe.wfl             #   the Scribe templating engine (vendored, pure WFL)
 ├─ include highlight.wfl          #   WFL → highlighted HTML
 ├─ include icons.wfl              #   inline Lucide-style SVG icons
 └─ site_render of route ...       #   build a context of plain maps + lists → render

build.wfl   →  site_render "/" , "/getting-started", "/404"  →  write public/*.html
serve.wfl   →  listen on port 8080; per request: site_render <route>  →  respond
```

Both entry points call the same `site_render` — `build.wfl` writes the result to
disk, `serve.wfl` responds with it live. The little footer line ("Generated as
static HTML…" vs "Rendered live by WFL…") is the only difference in the output,
so you can tell which one served a page.

The templates use Scribe's Twig-style syntax: `{% extends %}` / `{% block %}`
inheritance from `templates/base.html`, `{% include %}` for the shared nav and
footer partials, `{% for %}` loops over the nav links / feature cards / footer
columns, and `{{ value | raw }}` to emit trusted, pre-highlighted code HTML.

Every code sample on the site is colored by `lib/highlight.wfl` — a port of the
design system's `CodeBlock` token→color map into WFL. WFL keywords become teal,
strings amber, comments muted, exactly per the brand syntax theme. Nothing is
highlighted in the browser; WFL does it.

`serve.wfl` also streams the static assets: it reads `public/assets/*` (CSS,
the self-hosted Alegreya fonts, the SVG logo) with `read binary` and picks the
`Content-Type` from the file name via WFL's `mime_type` helper. Requests are
path-validated (`..` is rejected) before any file is opened.

## Build it yourself

You need the `wfl` CLI ([build it](https://github.com/WebFirstLanguage/wfl) with
`cargo build --release`). Everything runs from the repo root so the
`templates/…` and `public/…` paths resolve.

**Static build** — render to `public/*.html`:

```sh
scripts/build.sh /path/to/wfl     # or `scripts/build.sh` if wfl is on your PATH
# or directly:
wfl build.wfl
```

Then open `public/index.html`, or serve the folder with any static server:

```sh
cd public && python3 -m http.server 8000   # http://localhost:8000
```

**Live server** — WFL renders each page on every request:

```sh
scripts/serve.sh /path/to/wfl     # or `scripts/serve.sh`
# or directly:
wfl serve.wfl
# → open http://127.0.0.1:8080
```

The server binds to localhost by default. To expose it on a network (Docker,
etc.), set `web_server_bind_address = 0.0.0.0` in a `.wflcfg` file — see the
[WFL web-server docs](https://github.com/WebFirstLanguage/wfl/blob/main/Docs/04-advanced-features/web-servers.md).

> **Note.** WFL's static checker prints some non-fatal `could not infer type`
> notes to stderr for calls into the Scribe engine. The program still runs and
> exits `0` — this is expected (see Scribe's README).

## Editing the site

- **Copy & structure** — the templates in `templates/`. `base.html` is the
  shared page shell; each page extends it and fills the `content` block.
- **Data & routing** (nav links, feature cards, footer, code samples, routes) —
  `lib/site.wfl`. It's all plain WFL maps and lists, shared by the static build
  and the live server.
- **Design tokens** (colors, type, spacing, effects, syntax) — under
  `public/assets/tokens/` and `public/assets/styles.css`, taken verbatim from
  the WFL Design System. Site-specific layout and the component ports
  (buttons, cards, callouts, badges, code blocks) live in
  `public/assets/site.css`. Every value references a design-system token.

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
**JetBrains Mono** (code). The logo mark (`public/assets/img/wfl-mark.svg`) is
the provided brand mark — an outlined teal speech bubble with a chevron prompt
and a leaf cursor.

## Layout

```
wfl-web/
├── build.wfl                 # static: render every page → public/*.html
├── serve.wfl                 # live: WFL web server, render per request
├── lib/
│   ├── site.wfl              # shared model: content, routing, site_render
│   ├── scribe.wfl            # Scribe templating engine (vendored)
│   ├── highlight.wfl         # WFL-native syntax highlighter
│   └── icons.wfl             # inline SVG icon set
├── templates/
│   ├── base.html             # shared shell: <head>, nav, footer, content block
│   ├── index.html            # landing page
│   ├── getting-started.html  # docs page
│   ├── 404.html
│   └── partials/{nav,footer}.html
├── public/                   # ← deployable static output + assets
│   ├── index.html · getting-started.html · 404.html   (generated by build.wfl)
│   └── assets/               # design-system CSS tokens, fonts, logo, site.css
└── scripts/{build,serve}.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE). WFL and the Scribe engine are Apache-2.0;
the WFL Design System and brand assets are © Logbie LLC.
