# -------------------------
# Stage 1: Builder
# -------------------------
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Build-time arguments
ARG MONGODB_URI=mongodb://localhost:27017/easyshop
ARG REDIS_URI=redis://localhost:6379
ARG NEXTAUTH_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXTAUTH_SECRET
ARG JWT_SECRET

# Set environment variables
ENV MONGODB_URI=$MONGODB_URI \
    REDIS_URI=$REDIS_URI \
    NEXTAUTH_URL=$NEXTAUTH_URL \
    NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXTAUTH_SECRET=$NEXTAUTH_SECRET \
    JWT_SECRET=$JWT_SECRET \
    NODE_ENV=production \
    NEXT_PHASE=phase-production-build

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies (including dev for build)
RUN npm ci --include=dev && npm cache clean --force

# Copy source code
COPY . .

# Build Next.js production build
RUN npm run build

# -------------------------
# Stage 2: Production Image
# -------------------------
FROM node:18-alpine AS production

WORKDIR /app

# Install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy built app from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Set environment
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]

# -------------------------
# Notes:
# -------------------------
# 1. Multi-stage build reduces final image size by excluding dev dependencies.
# 2. npm cache is cleaned after install to save space.
# 3. Environment variables are injected via build args.
# 4. Use BuildKit for efficient builds:
#    DOCKER_BUILDKIT=1 docker build -t suyashdahitule/easyshop-app:latest .
