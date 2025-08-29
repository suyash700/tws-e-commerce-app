#----------------------
# BUILDER STAGE
#----------------------
FROM node:18-alpine AS builder

# Set build-time args (these can be overridden during docker build)
ARG MONGODB_URI=mongodb://localhost:27017/easyshop
ARG REDIS_URI=redis://localhost:6379
ARG NEXTAUTH_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXTAUTH_SECRET
ARG JWT_SECRET

# Set build environment variables
ENV MONGODB_URI=${MONGODB_URI} \
    REDIS_URI=${REDIS_URI} \
    NEXTAUTH_URL=${NEXTAUTH_URL} \
    NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL} \
    NEXTAUTH_SECRET=${NEXTAUTH_SECRET} \
    JWT_SECRET=${JWT_SECRET} \
    NEXT_PHASE=phase-production-build \
    NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies including devDependencies (needed for Next.js build)
RUN npm ci --include=dev

# Copy the rest of the source code
COPY . .

# Build Next.js application
RUN npm run build

#----------------------
# RUNNER STAGE
#----------------------
FROM node:18-alpine AS runner

WORKDIR /app

# Set runtime environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    MONGODB_URI=mongodb://mongodb:27017/easyshop \
    REDIS_URI=redis://redis:6379

# Copy only the necessary build artifacts from builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Expose application port
EXPOSE 3000

# Run the application
CMD ["node", "server.js"]
