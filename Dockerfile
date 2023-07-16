# Use the Node.js 18 base image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application code
COPY . .

# Expose the port that the app will listen on!!!!
EXPOSE 3000

# Start the application
CMD ["node", "index.js"]