# Stage 1: Base with dependencies and build tools
FROM node:20.9.0-alpine as base
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR /app
COPY package*.json ./
RUN npm install

# Stage 2: Build the Next.js app
FROM base as builder
WORKDIR /app
COPY . .
RUN npm run build

# Stage 3: Production using distroless
FROM gcr.io/distroless/nodejs20-debian12 as production
WORKDIR /app

# Copy only the production dependencies
COPY --from=base /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

# Use non-root user (distroless runs as non-root by default)
ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
