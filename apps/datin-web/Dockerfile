FROM node:20-alpine AS builder

WORKDIR /app

# Copy the entire monorepo
COPY . ./

# Install all dependencies for the monorepo
RUN npm install

# Build the web app
RUN npm run build --filter=datin-web

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy package.json files
COPY package.json ./
COPY apps/datin-web/package.json ./apps/datin-web/

# Copy built app from builder
COPY --from=builder /app/apps/datin-web/.next ./apps/datin-web/.next

EXPOSE 3000

ENV NODE_ENV production

WORKDIR /app/apps/datin-web

CMD ["npm", "start"]
