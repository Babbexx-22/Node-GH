FROM debian:bookworm-slim

ENV NODE_VERSION 18.16.1

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the application code
COPY . .

# Expose the port that the app will listen on!!!!
EXPOSE 3000

# Start the application
CMD ["node", "index.js"]