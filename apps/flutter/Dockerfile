# Multi-stage build for Flutter Web App
FROM debian:latest AS base

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME="/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
RUN flutter precache
RUN flutter doctor

WORKDIR /app

# Copy pubspec files
COPY pubspec*.yaml ./

# Get Flutter dependencies
RUN flutter pub get

# Development stage
FROM base AS development
COPY . .
RUN flutter pub get
EXPOSE 8080
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]

# Build stage
FROM base AS build
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Production stage with nginx
FROM nginx:alpine AS production

# Copy built web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"] 