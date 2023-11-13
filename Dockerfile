FROM ubuntu:22.04

# Expose port for mkdocs serve live html preview
EXPOSE 8000

# Needed to build image without user input
ARG DEBIAN_FRONTEND=noninteractive

# Env var for mkdocs to enable/disable pdf export
ENV ENABLE_PDF_EXPORT=0

# Env var for mkdocs run mode
ENV MKDOCS_MODE="build"

# Update
RUN apt-get update

# Install required packages
RUN apt-get install -y wget \
                       python3-pip \
                       libpangocairo-1.0-0 \
                       fonts-freefont-ttf

# Install mkdocs and required plug-ins
RUN pip3 install beautifulsoup4==4.9.3 \
                 mkdocs \
                 mkdocs-material \
                 mkdocs-material-extensions \
                 mkdocs-localsearch \
                 mkdocs-with-pdf

# Get and install Google-Chrome for the JavaScript Rendering
# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable

# Add the patched version of mkdocs_with_pdf
ADD mkdocs_with_pdf /usr/local/lib/python3.10/dist-packages/mkdocs_with_pdf

# Copy the build script and make it executable
COPY build_script.sh /root/build_script.sh
RUN chmod +x /root/build_script.sh

# When the container starts, run the build script
ENTRYPOINT [ "/bin/bash", "/root/build_script.sh" ]
