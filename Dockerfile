# Build the Flutter web app inside Docker, including regenerated web icons,
# then serve the static output with nginx.

FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/
COPY SiteIcon.png ./

RUN dart run flutter_launcher_icons
RUN flutter build web --release

FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/build/web/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
