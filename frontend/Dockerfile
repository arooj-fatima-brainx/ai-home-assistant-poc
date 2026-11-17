FROM node:24.22.3-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
CMD ["npm", "run", "dev"]
