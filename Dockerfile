# Base image

FROM nginx:1.25.4-alpine

# Remove default nginx website

RUN rm /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Copy custom configuration file and app

COPY app/index.html /usr/share/nginx/html/index.html
COPY app/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80

EXPOSE 80

# Perform a healthcheck to monitor webserver status

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD ["wget", "--quiet", "--tries=1", "--spider", "http://localhost:80/"]

# Start nginx server (on foreground mode)

CMD ["nginx", "-g", "daemon off;"]


