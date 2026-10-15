# Use Nginx as the base image
FROM nginx:alpine

# Copy custom Nginx config
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy static site content to Nginx's web root
COPY . /usr/share/nginx/html
