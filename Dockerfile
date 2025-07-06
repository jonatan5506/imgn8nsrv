FROM node:18-slim

# Instala Redis e ferramentas necessárias
RUN apt-get update && apt-get install -y \
    redis-server \
    curl \
    unzip \
    gnupg \
    python3 \
    python3-pip \
    supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Cria pastas
RUN mkdir -p /app/waha/.sessions /app/waha/.media /app/n8n /var/log/supervisor
WORKDIR /app

# Instala N8N
RUN npm install --prefix /app/n8n n8n

# Baixa o WAHA
RUN curl -L https://github.com/devlikeapro/waha/releases/latest/download/waha-linux.zip -o waha.zip && \
    unzip waha.zip -d /app/waha && \
    chmod +x /app/waha/waha && \
    rm waha.zip

# Copia o arquivo de supervisão
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Variáveis de ambiente
ENV REDIS_PASSWORD=default \
    WHATSAPP_HOOK_URL=http://localhost:5678/webhook/webhook \
    WHATSAPP_DEFAULT_ENGINE=GOWS \
    WHATSAPP_HOOK_EVENTS=message \
    N8N_PORT=5678 \
    N8N_PROTOCOL=http \
    GENERIC_TIMEZONE=America/Sao_Paulo \
    N8N_LOG_LEVEL=debug \
    N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true \
    N8N_SECURE_COOKIE=false

# Porta padrão
EXPOSE 6379 5678 3000

# Inicia todos os serviços
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
