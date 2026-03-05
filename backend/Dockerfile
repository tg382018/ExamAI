FROM node:20-alpine

# C library compatibility for Prisma
RUN apk add --no-cache libc6-compat openssl

WORKDIR /app

# Install dependencies first for better caching
COPY package*.json ./
COPY tsconfig.json ./
# Prisma schema needs to be copied before npm install
COPY prisma ./prisma/

RUN npm install

# Copy source code and start script
COPY src ./src
COPY prisma.config.ts ./
COPY start.sh ./
RUN chmod +x start.sh

# Generate Prisma Client specifically for Linux Alpine
RUN npx prisma generate

# Build TypeScript
RUN npm run build

# Expose API port
EXPOSE 3000

# Start command
CMD ["./start.sh"]
