# Use Cirrus CI's Flutter image as a base
FROM cirrusci/flutter:3.27.0

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Ensure dependencies are fetched
RUN flutter pub get

# Build the release APK
RUN flutter build apk --release

# The APK will be available in build/app/outputs/flutter-apk/app-release.apk
