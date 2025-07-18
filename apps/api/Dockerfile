# Use the official Node.js image as the base image
FROM node:22.3

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install --unsafe-perm=true --allow-root

# Copy the rest of the application code
COPY . .

# Build the Next.js application for production
RUN npm run build


# Expose port 5000 to the outside world
EXPOSE 5000

# Command to run the application
CMD ["npm", "start"]
