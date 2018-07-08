FROM nginx

RUN apt-get update && apt-get install -y vim

COPY index.html /usr/share/nginx/html/

CMD nginx -g 'daemon off;'
