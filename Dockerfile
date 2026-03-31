FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404

ENV PYTHONUNBUFFERED=1
WORKDIR /

RUN apt-get update --yes && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
    git \
    curl \
    wget \
    zip \
    libgoogle-perftools4 && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip

COPY instructions.txt /instructions.txt
COPY start.sh /start.sh
COPY install.sh /install.sh
COPY handlers /handlers

RUN chmod +x /start.sh /install.sh

EXPOSE 8188 8888

CMD ["/start.sh"]
