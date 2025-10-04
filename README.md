# Portfolio Site

> NOTE: This repository contains a Flutter web app located in the `lib/` folder. The Flutter app is intentionally configured and supported for web only. Non-web platforms (iOS, Android, macOS, Windows, Linux) are not supported in this workspace. See `WEB_ONLY.md` for details.

This repository contains the source code for my **personal portfolio site**, built using **Streamlit**.  
The site serves as a showcase of my projects, including **AI tools, game development work, and automation scripts**.  

**This portfolio site is hosted on [Google Cloud Run](https://cloud.google.com/run)**, allowing for **scalable, containerized deployment**.


## Features
- **Project Listings** – Organized into categories (Featured, Projects, Mini Projects, Translations).
- **Dynamic Filtering** – Sidebar allows filtering projects by tags.
- **Interactive Design** – Uses Streamlit for a simple, clean UI.
- **Deployment with Docker & Google Cloud Run** – Containerized for cloud hosting.


## Running the Portfolio Locally

### **Clone the Repository**
```bash
git clone https://github.com/dragonstonehafiz/portfolio-site.git
cd portfolio-site
```

### **Install Dependencies**
This project uses **Streamlit**. Install the required packages:
```bash
pip install -r requirements.txt
```

### **Run the Site**
```bash
streamlit run 1_🏠︎_HomePage.py
```
The portfolio should now be accessible at **`http://localhost:8501`**.


## Building a Docker Image

To run the site inside a Docker container:

```bash
docker build -t portfolio .
docker run -p 8080:8080 portfolio
```

## Deploying to Google Cloud Run

This site is **hosted on Google Cloud Run**, which allows for easy **serverless deployment**.

### **Deployment Steps**
1. Build and tag the Docker image:
   ```bash
   docker tag <image-id> <your-registry-url>/portfolio-image
   ```
2. Push the image to **Google Cloud Artifact Registry**:
   ```bash
   docker push <your-registry-url>/portfolio-image
   ```
3. Deploy to **Google Cloud Run**:
   - Navigate to [Google Cloud Run Console](https://console.cloud.google.com/run).
   - Select your project and deploy the new image.

*Replace `<your-registry-url>` with the actual Google Cloud Artifact Registry URL.*  
For detailed setup, refer to [Google Cloud's documentation](https://cloud.google.com/run/docs/deploying).
