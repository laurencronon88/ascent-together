Ascent Together 2026 — Landing Page Package
===========================================

CONTENTS
--------
  index.html              Main landing page (open this in a browser)
  assets/
    logo.svg              Convention SVG logo (vector, fully local)
    harrahs-hero.jpg      Harrah's Cherokee hero photo         ← run script
    convention-lockup.png Convention branding lockup PNG       ← run script
    harrahs-logo.png      Harrah's resort logo (white)         ← run script
    speaker-creed.jpg     Greg Creed headshot                  ← run script
    speaker-noone.jpg     Patrick Noone headshot               ← run script
  fonts/
    google-fonts.css      Font stylesheet (points to Google CDN until script runs)
  download-assets.sh      One-time setup script (see below)
  README.txt              This file


QUICK START
-----------
1. Open index.html in any browser — the page loads immediately using
   Google Fonts and Wix-hosted images via CDN. No setup needed for preview.

2. To make the package FULLY self-contained (offline / deploy anywhere):

     chmod +x download-assets.sh
     ./download-assets.sh

   This downloads all images and font files into assets/ and fonts/,
   then rewrites google-fonts.css to use local paths. After that the
   package requires zero internet connection to display correctly.


WHAT STAYS EXTERNAL (intentional)
-----------------------------------
These are interactive services — they must remain as external links:

  https://forms.office.com/r/8Ki3rnzkp2     — Registration form (Microsoft)
  https://book.passkey.com/go/S07AHMA       — Hotel booking (Passkey/Marriott)
  https://73656bde-c1b2...pdf               — Agenda PDF (Wix file storage)


DEPLOYING
---------
After running download-assets.sh, the entire folder is a static site.
Drop it on any host:

  • GitHub Pages       — push folder, enable Pages in repo settings
  • Netlify            — drag and drop the folder at app.netlify.com
  • Vercel             — run: npx vercel
  • AWS S3             — sync folder, enable static website hosting
  • Any web server     — copy folder to public_html / www root


UPDATING CONTENT
----------------
All content is in index.html. Search for section comments like:
  <!-- HERO -->  <!-- SPEAKERS -->  <!-- AGENDA -->  <!-- VENUE -->
to find and edit each section quickly.


CONTACT
-------
  General questions:   cstory@ascenthm.com
  Vendor village:      sstewart@ascenthm.com
  Hotel reservations:  828-497-7777  ·  Group code S07AHMA
