#BUILDER

##Stage 1

#Base Image
FROM node:18-alpine as builder

#BUILD-TIME ENV VARS
# Add build-time environment variables
ARG MONGODB_URI=mongodb://localhost:27017/easyshop
ARG REDIS_URI=redis://localhost:6379
ARG NEXTAUTH_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXTAUTH_SECRET
ARG JWT_SECRET
ARG NODE_ENV=production

# Set environment variables for the build
ENV MONGODB_URI=$MONGODB_URI \
    REDIS_URI=$REDIS_URI \
    NEXTAUTH_URL=$NEXTAUTH_URL \
    NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXTAUTH_SECRET=$NEXTAUTH_SECRET \
    JWT_SECRET=$JWT_SECRET \
    NODE_ENV=$NODE_ENV \
    NEXT_PHASE=phase-production-build


#WORKDIR
WORKDIR /app

#COPY
COPY package*.json

#CLEAN INSTALL
npm ci

#COPY REMAINING FILES FOLDERS TO BUILDER STAGE (/app)
COPY . . 

#BUILD IT
RUN npm run build

#RUNNER

##STAGE 2

#BASE Image

FROM node:18-alpine as builder

#WORKDIR
WORKDIR /app

#SET ENV VARS

ENV NODE_ENV=production \
    PORT=3000 \
    # These are placeholder values that will be overridden at runtime
    MONGODB_URI=mongodb://mongodb:27017/easyshop \
    REDIS_URI=redis://redis:6379


#COPY NECESSARY FILES
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next ./.next
COPY --from=builder /app/node_modules ./node_modules

#EXPOSE PORT
EXPOSE 3000

#SERVE
CMD ["npm","start"]
