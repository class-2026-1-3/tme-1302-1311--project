FROM nginx:alpine

COPY web/nginx.conf /etc/nginx/conf.d/default.conf

COPY web/css/ /usr/share/nginx/html/css/
COPY web/html/ /usr/share/nginx/html/html/
COPY web/public/ /usr/share/nginx/html/public/
COPY doback2.js /usr/share/nginx/html/js/doback2.js

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
