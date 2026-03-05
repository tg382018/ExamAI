#!/bin/sh
echo "Running Prisma migrations..."
export DATABASE_URL="postgresql://user:password@db:5432/examai"
npx prisma migrate deploy

echo "Starting server..."
npm start
