# Compte Rendu : Déploiement Automatisé d’une Infrastructure Cloud avec Terraform

L'objectif était de déployer une infrastructure cloud complète en utilisant Terraform pour automatiser la création d'une machine virtuelle (VM) et d'un stockage cloud sur AWS. 

## Étape 1 : Préparation de l’Environnement Terraform
Installation de Terraform et Configuration du Provider AWS

Création des Fichiers Terraform

Les fichiers suivants ont été créés :

- main.tf : Contient la définition des ressources AWS.

- variables.tf : Définit les variables utilisées dans le projet.

- outputs.tf : Affiche les informations importantes comme l'IP publique de la VM.

- provider.tf : Configure le provider AWS.

Étape 2 : Déploiement de l’Infrastructure
Création de la Machine Virtuelle

Une instance EC2 a été créée avec Terraform en utilisant Ubuntu. Une IP publique a été associée à l'instance pour permettre l'accès externe. Voici un extrait de la configuration :
 ```sh
   resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "FlaskAppServer"
  }
}
 ```

- Création du Stockage Cloud

Un bucket S3 a été créé pour stocker les fichiers statiques. Les permissions ont été configurées pour restreindre l'accès public. Voici un extrait de la configuration :

 ```sh
resource "aws_s3_bucket" "static_files" {
  bucket = "my-static-files-bucket"
  acl    = "private"

  tags = {
    Name = "StaticFiles"
  }
}
```

Le backend Flask a été déployé sur la VM. Les dépendances ont été installées via un script de provisioning. Voici un extrait du script :

```ssh
sudo apt-get update
sudo apt-get install -y python3-pip
pip3 install flask
```
## Étape 3 : Connexion du Backend au Stockage et Implémentation d’un CRUD
Configuration de l’Application Flask

L'application Flask a été configurée pour interagir avec le bucket S3. Les fichiers statiques sont stockés et récupérés via l'API Boto3. Voici un extrait du code Flask :
```ssh
from flask import Flask, request
import boto3

app = Flask(__name__)
s3 = boto3.client('s3')

@app.route('/upload', methods=['POST'])
def upload_file():
    file = request.files['file']
    s3.upload_fileobj(file, 'my-static-files-bucket', file.filename)
    return 'File uploaded successfully'
```
## Étape 4 : Automatisation du Déploiement avec Terraform
Gestion des Variables et Outputs

Les variables ont été définies dans variables.tf et les valeurs sensibles ont été stockées dans terraform.tfvars. Les outputs ont été configurés pour afficher l'IP publique de la VM :

```ssh
output "public_ip" {
  value = aws_instance.web.public_ip
}
```


## Destruction de l’Infrastructure

L'infrastructure a été détruite proprement en utilisant la commande terraform destroy.




Dépôt GitHub : Lien vers le dépôt GitHub

Références
Documentation Terraform : https://www.terraform.io/docs

Documentation AWS : https://aws.amazon.com/documentation/
