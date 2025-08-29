#----------------------
# BUILDER STAGE
#----------------------
FROM node:18-alpine AS builder

# Set build-time args
ARG MONGODB_URI=mongodb://localhost:27017/easyshop
ARG REDIS_URI=redis://localhost:6379
ARG NEXTAUTH_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXTAUTH_SECRET
ARG JWT_SECRET

# Set environment variables for build
ENV MONGODB_URI=$MONGODB_URI \
    REDIS_URI=$REDIS_URI \
    NEXTAUTH_URL=$NEXTAUTH_URL \
    NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXTAUTH_SECRET=$NEXTAUTH_SECRET \
    JWT_SECRET=$JWT_SECRET \
    NODE_ENV=development \
    NEXT_PHASE=phase-production-build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies)
RUN npm ci --include=dev

# Copy application source
COPY . .

# Build the Next.js app
RUN npm run build

#----------------------
# RUNNER STAGE
#----------------------
FROM node:18-alpine AS runner

# Set working directory
WORKDIR /app

# Set environment variables for runtime
ENV NODE_ENV=production \
    PORT=3000 \
    MONGODB_URI=mongodb://mongodb:27017/easyshop \
    REDIS_URI=redis://redis:6379

# Copy only necessary build artifacts
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next

# Install only production dependencies
RUN npm ci --only=production

# Expose port
EXPOSE 3000

# Start the server
CMD ["node", "server.js"]
