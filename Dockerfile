#----------------------
# BUILDER STAGE
#----------------------
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dev dependencies
RUN npm ci --include=dev && npm cache clean --force

# Copy project files
COPY . .

# Build Next.js app
RUN npm run build

#----------------------
# RUNNER STAGE
#----------------------
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production \
    PORT=3000 \
    MONGODB_URI=mongodb://mongodb:27017/easyshop \
    REDIS_URI=redis://redis:6379

# Copy only necessary files
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

EXPOSE 3000

CMD ["node", "server.js"]
