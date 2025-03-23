#!/bin/bash

connection_string="$1"

apt update -y
apt install -y python3 python3-pip
pip3 install flask azure-storage-blob

# Application Flask
mkdir -p /app
cat <<EOF > /app/app.py
from flask import Flask, request
from azure.storage.blob import BlobServiceClient
import os

app = Flask(__name__)
conn_str = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
blob_service_client = BlobServiceClient.from_connection_string(conn_str)
container_client = blob_service_client.get_container_client("staticfiles")

@app.route("/")
def index():
    return "Flask App running with Azure Blob Storage"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

# Injecte proprement la connection string
echo "export AZURE_STORAGE_CONNECTION_STRING='$connection_string'" >> /etc/profile
source /etc/profile

# Création du service Flask
cat <<EOF > /etc/systemd/system/flask.service
[Unit]
Description=Flask Application
After=network.target

[Service]
EnvironmentFile=-/etc/profile
ExecStart=/usr/bin/python3 /app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Démarrer le service
systemctl daemon-reload
systemctl enable flask
systemctl start flask
