# Portfolio Site

This repository contains the source code for my **personal portfolio site**, built using **Flutter for Web**.  
The site serves as a showcase of my projects, including **AI tools, game development work, and automation scripts**.

**This portfolio site is configured for web deployment only.** Native mobile and desktop platforms (iOS, Android, macOS, Windows, Linux) have been removed to keep the project focused and lightweight.

## Features
- **Project Listings** – Organized into categories (Featured, Projects, Translations).
- **Dynamic Project Pages** – Each project has its own URL at `/projects/<project-name>`.
- **Markdown Support** – Project descriptions and details support full Markdown formatting.
- **Responsive Design** – Optimized for both desktop and mobile web browsers.
- **Static Web Deployment** – Builds to static files for easy hosting.

## Development Setup

### **Clone the Repository**
```bash
git clone https://github.com/dragonstonehafiz/portfolio-site.git
cd portfolio-site
```

### **Install Dependencies**
This project requires **Flutter**. Install the required packages:
```bash
flutter pub get
```

### **Run the Development Server**
```bash
flutter run -d chrome
```
The portfolio will open in Chrome and be accessible at `http://localhost:<port>`.

### **Build for Production**
```bash
flutter build web --release
```
The built files will be in the `build/web/` directory.

### **Host the built site locally (Python)**

From the project root (where `build/web/` is), you can serve the production build with a tiny Python HTTP server. Choose one of the following depending on your Python version:

- Python 3 (recommended):
```powershell
python -m http.server 8080 --directory build/web
```

- Python 2 (if available):
```powershell
python -m SimpleHTTPServer 8080
```

Then open http://localhost:8080 in your browser.

## Deployment

The built web files can be hosted on any static hosting service:

- **GitHub Pages** – Upload `build/web/` contents to your GitHub Pages repository.
- **Netlify/Vercel** – Connect your repository and set build command to `flutter build web --release`.
- **Firebase Hosting** – Use `firebase deploy` after building.
- **Any Web Server** – Serve the `build/web/` directory as static files.

### **Docker Container**

You can also create a Docker container using the built web files:

1. **Build the Flutter web app:**
   ```bash
   flutter build web --release
   ```

2. **Create a Dockerfile**:
   ```dockerfile
   FROM python:3.9-slim
   EXPOSE 8080
   WORKDIR /app
   COPY build/web/ ./
   ENTRYPOINT ["python", "-m", "http.server", "8080"]
   ```

   **Alternative with nginx (more production-ready):**
   ```dockerfile
   FROM nginx:alpine
   COPY build/web/ /usr/share/nginx/html/
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

3. **Build and run the Docker container:**
   ```bash
   docker build -t portfolio .
   docker run -p 8080:8080 portfolio
   ```
   
   The site will be available at `http://localhost:8080`.

### **Google Cloud Deployment**

To deploy the Docker container to Google Cloud Run:

1. **Build and tag the Docker image:**
   ```bash
   docker tag <image-id> <your-registry-url>/portfolio-image
   ```

2. **Push the image to Google Cloud Artifact Registry:**
   ```bash
   docker push <your-registry-url>/portfolio-image
   ```

3. **Deploy to Google Cloud Run:**
   - Navigate to [Google Cloud Run Console](https://console.cloud.google.com/run).
   - Select your project and deploy the new image.

*Replace `<your-registry-url>` with the actual Google Cloud Artifact Registry URL.*  
For detailed setup, refer to [Google Cloud's documentation](https://cloud.google.com/run/docs/deploying).

## Project Structure

- `lib/` – Flutter source code
- `web/` – Web-specific configuration and assets
- `assets/` – Project data (JSON) and images
- `build/web/` – Generated web build output

## Web-Only Configuration

This repository is intentionally configured for web deployment only. The following platform directories have been removed:
- `android/`, `ios/`, `macos/`, `windows/`, `linux/`

To restore support for other platforms, run `flutter create .` in the project root, though this will require additional platform-specific configuration.
