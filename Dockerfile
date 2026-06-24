# ── Gideon Personal AI OS — Production Dockerfile ───────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --prefer-offline

# Copy source
COPY . .

# Build client + server
RUN npm run build

# ── Production image ─────────────────────────────────────────────────────────
FROM node:22-alpine AS production

WORKDIR /app

RUN apk add --no-cache curl

# Copy built artifacts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Create data dirs
RUN mkdir -p /app/data /app/generated /app/qdrant_storage

# Gideon runs on port 5000
EXPOSE 5000

ENV NODE_ENV=production
ENV PORT=5000

CMD ["node", "dist/index.cjs"]
