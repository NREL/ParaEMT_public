# Start your image with a node base image
FROM python:3.11.10

# The /app directory should act as the main application directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the ParaEMT_public repository from GitHub
# RUN git clone --branch test https://github.com/NREL/ParaEMT_public.git .

# Install Python dependencies
# Copy all local files into the container
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt

# Install Jupyter Notebook for interactive use
RUN pip install jupyter

# Expose port for Jupyter Notebook
EXPOSE 8888

# Run Jupyter Notebook and open access to all IPs on port 8888
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
