# =========================
# Stage 1: Build Angular app
# =========================
FROM node:12 AS build

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

# Give Node.js more heap
ENV NODE_OPTIONS=--max-old-space-size=4096

RUN npm run build -- --prod


# =========================
# Stage 2: NGINX (runtime)
# =========================
FROM nginx:alpine

# Copy Angular build output
COPY --from=build /usr/src/app/dist /usr/share/nginx/html

# 👉 COPY env template (NEW)
COPY env.template.js /usr/share/nginx/html/env.template.js

# 👉 Generate env.js at container start (NEW)
CMD ["/bin/sh", "-c", \
  "envsubst < /usr/share/nginx/html/env.template.js > /usr/share/nginx/html/env.js && nginx -g 'daemon off;'"]

EXPOSE 80
