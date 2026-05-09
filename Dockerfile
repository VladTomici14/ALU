# Use Ubuntu as base image
FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    iverilog \
    gtkwave \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Make sure the script is executable (though it should be)
RUN chmod +x run_sim.sh

# Default command to run the simulation
CMD ["./run_sim.sh"]