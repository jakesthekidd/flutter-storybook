# flutter-storybook

A Storybook for Flutter widgets, built with [`storybook_flutter`](https://pub.dev/packages/storybook_flutter).

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Add a story

1. Create a file in `lib/stories/`.
2. Export a `List<Story>`.
3. Spread it into the `stories:` list in `lib/main.dart`.

## Build for the web

```bash
flutter build web --release --base-href "/flutter-storybook/"
```

The built site lands in `build/web/` and is suitable for GitHub Pages.

## Deploy to GitHub Pages

This repo includes a workflow at `.github/workflows/deploy.yml` that builds the
web app and publishes it on every push to `main`. Enable Pages in repo settings
(Source: GitHub Actions). The site will be at
`https://<user>.github.io/flutter-storybook/`.
