# Wallora 4K Wallpaper

Browse bundled wallpapers, save to Photos, and keep favorites on-device. No ads.

## Run

```bash
flutter pub get
flutter run
```

## App Store (iOS)

1. Apple Developer account + App ID `com.wallora.wallpaper`
2. Xcode → Runner → **Signing & Capabilities** → your Team → **Archive** → upload
3. Host [`docs/PRIVACY_POLICY.md`](docs/PRIVACY_POLICY.md) publicly; add URL in App Store Connect
4. App Privacy: Photos (user-initiated save), on-device favorites, no tracking, no ads
5. Screenshots and description must match the app (no ads)
6. You must own or license all images in `assets/`

```bash
flutter build ipa
```
