FROM docker.io/library/nginx:stable

ARG BACKEND_URL
ARG BUFFER_RESPONSES=on

RUN echo "server {\n\
  listen 80;\n\
  client_max_body_size 0;\n\

  location / {\n\
    proxy_pass $BACKEND_URL;\n\
    proxy_set_header Host \$host;\n\
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n\
    proxy_set_header X-Real-IP \$remote_addr;\n\
    proxy_buffering $BUFFER_RESPONSES;\n\
  }\n\
}" > /etc/nginx/conf.d/default.conf

