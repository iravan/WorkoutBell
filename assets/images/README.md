# App Icon

To use your own app icon:

1. **Create your icon**: Design a 1024x1024 pixel PNG image for your app icon
2. **Place the icon**: Save it as `app_icon.png` in this directory (`assets/images/app_icon.png`)
3. **Generate icons**: Run the following command to generate all required icon sizes:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

This will automatically generate all the required icon sizes for:
- Android (all density folders: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- iOS (all required sizes for iPhone and iPad)

**Note**: Make sure your icon image is:
- Square (1024x1024 pixels recommended)
- PNG format
- Has no transparency (for best results)
- Follows platform design guidelines

