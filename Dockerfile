# Production-ready Dockerfile to serve Flutter web build via nginx
# Build the web app locally: flutter build web --release
# Then build this image in the project root (which contains build/web)

FROM nginx:alpine

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy our SPA build output
COPY build/web/ /usr/share/nginx/html/

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
