# Use official Node.js LTS version as base image
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /app

# Copy only package.json and package-lock.json first (for caching dependencies)
COPY package*.json ./

# Install dependencies (production only)
RUN npm install --production

# Copy the rest of the application files
COPY . .

# Expose the port your app listens on
EXPOSE 3000

# Default command to run the app
CMD ["npm", "start"]
