# Minimalbeispiel: AWS S3 Bucket mit Terraform erstellen

Diese Anleitung zeigt dir **Schritt für Schritt**, wie du mit Terraform und dem **AWS Provider** einen einfachen **S3-Bucket** erstellst.  
Zusätzlich ist das Beispiel wieder **sauber auf mehrere Terraform-Dateien aufgeteilt**.

---

## Ziel

Am Ende hast du:

- ein kleines Terraform-Projekt für AWS
- eine sinnvolle Aufteilung in mehrere `.tf`-Dateien
- einen S3-Bucket, der per Terraform erstellt wird
- ein besseres Verständnis dafür, **was intern bei Terraform und AWS passiert**

---

## Was passiert hier in der Praxis?

Wenn du Terraform mit AWS verwendest, läuft intern ungefähr Folgendes ab:

1. Terraform lädt den AWS Provider
2. Der Provider nutzt deine AWS-Konfiguration und Credentials
3. Terraform vergleicht den gewünschten Zustand mit der Realität
4. Der AWS Provider ruft die AWS-API auf
5. AWS erstellt die gewünschte Ressource
6. Terraform speichert den Zustand in der State-Datei

Das ist wichtig:  
Terraform erstellt die Ressource **nicht selbst direkt**, sondern spricht über den Provider mit der **AWS-API**.

---

## Voraussetzungen

Du brauchst:

- ein AWS-Konto
- Terraform installiert
- AWS CLI installiert
- gültige AWS-Zugangsdaten
- ein Terminal

---

## Projektstruktur

Erstelle zuerst einen neuen Ordner:

```bash
mkdir terraform-aws-s3-demo
cd terraform-aws-s3-demo
```

Danach legen wir diese Dateien an:

```text
terraform-aws-s3-demo/
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
└── .gitignore
```

---

## Schritt 1: AWS CLI vorbereiten

Prüfe zuerst, ob die AWS CLI installiert ist:

```bash
aws --version
```

Wenn ein Versionsstring angezeigt wird, ist alles gut.

---

## Schritt 2: AWS Credentials konfigurieren

Nun richtest du deine Zugangsdaten ein:

```bash
aws configure
```

Dann gibst du ein:

- AWS Access Key ID
- AWS Secret Access Key
- Default region name
- Default output format

Ein Beispiel:

```text
AWS Access Key ID [None]: DEIN_ACCESS_KEY
AWS Secret Access Key [None]: DEIN_SECRET_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

### Was passiert dabei?

Die AWS CLI speichert deine Zugangsdaten lokal, meist in:

```text
~/.aws/credentials
~/.aws/config
```

Der Terraform AWS Provider kann diese Konfiguration später automatisch verwenden.

---

## Schritt 3: Credentials und Region testen

Teste, ob AWS grundsätzlich erreichbar ist:

```bash
aws sts get-caller-identity
```

Wenn alles korrekt eingerichtet ist, bekommst du Informationen zu deinem AWS-Konto zurück.

Das ist ein guter Test, bevor du mit Terraform startest.

---

## Schritt 4: Datei `provider.tf`

Hier definierst du Terraform und den AWS Provider.

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### Erklärung

- `required_version`: minimale Terraform-Version
- `required_providers`: sagt Terraform, welchen Provider es laden soll
- `provider "aws"`: bindet den AWS Provider ein
- `region = var.aws_region`: die AWS-Region kommt aus einer Variablen

---

## Schritt 5: Datei `variables.tf`

Hier definierst du die Eingabewerte.

```hcl
variable "aws_region" {
  description = "AWS-Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name des S3-Buckets"
  type        = string
}

variable "bucket_tags" {
  description = "Tags für den S3-Bucket"
  type        = map(string)
  default = {
    project = "terraform-demo"
    owner   = "demo"
  }
}
```

### Erklärung

- `aws_region`: Region für AWS
- `bucket_name`: Name des Buckets
- `bucket_tags`: kleine Metadaten für den Bucket

Wichtig:  
Ein S3-Bucket-Name muss **weltweit eindeutig** sein.  
Wenn der Name schon existiert, schlägt das Erstellen fehl.

---

## Schritt 6: Datei `main.tf`

Hier definierst du die eigentliche Ressource.

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}
```

### Erklärung

- `aws_s3_bucket`: Ressourcentyp für einen S3-Bucket
- `"demo"`: interner Terraform-Name
- `bucket = var.bucket_name`: Name aus der Variablen
- `tags = var.bucket_tags`: Tags aus der Variable

---

## Schritt 7: Datei `outputs.tf`

Mit Outputs lässt du dir wichtige Informationen ausgeben.

```hcl
output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.demo.arn
}

output "bucket_region" {
  value = var.aws_region
}
```

### Erklärung

Nach `terraform apply` bekommst du damit direkt wichtige Informationen zurück.

---

## Schritt 8: Datei `terraform.tfvars`

Hier setzt du die konkreten Werte für dein Projekt.

```hcl
aws_region  = "us-east-1"
bucket_name = "mein-eindeutiger-demo-bucket-xyz-12345"
# bucket_name erlaubt nur "kleine" Buchstaben

bucket_tags = {
  project = "terraform-demo"
  owner   = "unterricht"
}
```

### Wichtig

Ersetze `mein-eindeutiger-demo-bucket-xyz-12345` durch einen **wirklich eindeutigen Namen**. Achte außerdem darauf, dass du den [AWS General purpose bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html) folgst, da du sonst einen Fehler bekommst.
Zum Beispiel mit deinem Namen oder einem Zufallswert.

---

## Schritt 9: Datei `.gitignore`

Wenn du das Projekt in Git speicherst, sollte diese Datei dabei sein:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
crash.log
.terraform.lock.hcl
```

### Warum?

Terraform speichert den Zustand lokal in State-Dateien.  
Diese sollten nicht einfach unüberlegt in ein Repository committed werden.

---

## Gesamtübersicht aller Dateien

## `provider.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

## `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS-Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name des S3-Buckets"
  type        = string
}

variable "bucket_tags" {
  description = "Tags für den S3-Bucket"
  type        = map(string)
  default = {
    project = "terraform-demo"
    owner   = "demo"
  }
}
```

## `main.tf`

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}
```

## `outputs.tf`

```hcl
output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.demo.arn
}

output "bucket_region" {
  value = var.aws_region
}
```

## `terraform.tfvars`

```hcl
aws_region  = "us-east-1"
bucket_name = "mein-eindeutiger-demo-bucket-xyz-12345"

bucket_tags = {
  project = "terraform-demo"
  owner   = "unterricht"
}
```

---

## Schritt 10: Terraform initialisieren

```bash
terraform init
```

### Was passiert intern?

- Terraform liest deine `.tf`-Dateien
- erkennt, dass der AWS Provider gebraucht wird
- lädt den Provider herunter
- legt den Ordner `.terraform` an

---

## Schritt 11: Ausführungsplan ansehen

```bash
terraform plan
```

### Was passiert intern?

Terraform prüft:

- Was steht in deinen Dateien?
- Gibt es den Bucket schon?
- Was muss neu erstellt werden?

Dann zeigt Terraform dir den geplanten Unterschied zwischen:

- **Soll-Zustand** = dein Code
- **Ist-Zustand** = aktuelle AWS-Realität

Hier wird noch nichts erstellt.

---

## Schritt 12: Bucket erstellen

```bash
terraform apply
```

Terraform zeigt dir den Plan noch einmal an und fragt nach einer Bestätigung.

Bestätige mit:

```text
yes
```

Danach passiert intern Folgendes:

1. Terraform sendet die Anforderung an den AWS Provider
2. Der AWS Provider ruft die AWS-API auf
3. AWS erstellt den S3-Bucket
4. Terraform speichert die Ressource in der State-Datei

---

## Schritt 13: Ergebnis in AWS prüfen

Öffne die AWS-Konsole und gehe zu **S3**.

Dort solltest du deinen Bucket sehen.

Du kannst nun prüfen:

- stimmt der Name?
- ist der Bucket in der richtigen Region?
- wurden die Tags gesetzt?

---

## Schritt 14: Änderung testen

Ändere zum Beispiel in `terraform.tfvars` einen Tag:

```hcl
bucket_tags = {
  project = "terraform-demo"
  owner   = "kurs"
}
```

Dann wieder:

```bash
terraform plan
terraform apply
```

So siehst du, wie Terraform auch bestehende Ressourcen verwaltet und Änderungen erkennt.

---

## Schritt 15: Bucket wieder löschen

Zum Aufräumen:

```bash
terraform destroy
```

Dann bestätigst du wieder mit:

```text
yes
```

Danach löscht Terraform den Bucket wieder über die AWS-API.

---

## Warum die Aufteilung in mehrere Dateien sinnvoll ist

Die Aufteilung sorgt für mehr Übersicht:

- `provider.tf` → Provider und Terraform-Konfiguration
- `variables.tf` → Eingabewerte
- `main.tf` → eigentliche Ressourcen
- `outputs.tf` → Ausgaben
- `terraform.tfvars` → konkrete Projektwerte

Gerade bei AWS wird das später sehr hilfreich, weil Projekte schnell größer werden.

---

## Typischer Ablauf nochmal kurz

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

## Häufige Fehler

## 1. Bucket-Name ist nicht eindeutig

S3-Bucket-Namen sind global eindeutig.  
Wenn der Name schon vergeben ist, schlägt das Erstellen fehl.

### Lösung

Wähle einen individuellen Namen, zum Beispiel:

```text
max-muster-terraform-demo-bucket-2026
```

---

## 2. Keine oder falsche AWS Credentials

Wenn deine Zugangsdaten nicht stimmen, kann Terraform AWS nicht ansprechen.

### Lösung

Prüfe mit:

```bash
aws sts get-caller-identity
```

Wenn das nicht funktioniert, erst AWS CLI sauber konfigurieren.

---

## 3. Falsche Region

Wenn du in der falschen Region arbeitest, suchst du den Bucket später eventuell an der falschen Stelle.

### Lösung

Region in `terraform.tfvars`, AWS CLI und AWS-Konsole vergleichen.

---

## 4. Bucket ist nicht leer beim Löschen

Manchmal kann ein Bucket nicht gelöscht werden, wenn noch Inhalte darin liegen.

In diesem ganz einfachen Beispiel passiert das oft nicht, solange du nichts hochgeladen hast.

Falls du später Dateien in den Bucket legst, musst du ihn erst leeren.

---

## Erweiterungsideen

Wenn das Grundbeispiel funktioniert, kannst du später erweitern:

- Bucket-Versionierung aktivieren
- Verschlüsselung konfigurieren
- Public Access Block setzen
- Lifecycle Rules definieren
- Dateien mit Terraform hochladen
- IAM-Rollen und Policies ergänzen

---

## Mini-Variante für schnellen Unterrichtseinstieg

Wenn du erst einmal nur das absolute Minimum zeigen willst, reichen diese zwei Dateien:

### `provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### `main.tf`

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "mein-eindeutiger-demo-bucket-xyz-12345"
}
```

Danach:

```bash
terraform init
terraform apply
```

---

## Noch besser für die Praxis: Sichere Basisversion

Für ein realistischeres Einstiegsszenario kannst du zusätzlich gleich einen Public-Access-Block definieren.

### `main.tf`

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}

resource "aws_s3_bucket_public_access_block" "demo_block" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Warum ist das sinnvoll?

So zeigst du direkt, dass ein Bucket nicht einfach öffentlich erreichbar sein sollte.  
Das ist für Unterricht und Praxis oft die bessere Version.

---

## Fazit

Mit diesem Beispiel hast du ein einfaches, aber realistisches Terraform-Projekt für AWS aufgebaut:

- AWS Provider eingebunden
- Variablen ausgelagert
- S3-Bucket als Ressource definiert
- Outputs ergänzt
- Werte über `terraform.tfvars` gesetzt
- Terraform-Befehle praktisch verwendet
- verstanden, was intern über Provider und AWS-API passiert

Das ist eine sehr gute Grundlage für weitere AWS-Ressourcen wie EC2, IAM oder VPC.


## Bucket Policy implimented ##
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::mein-eindeutiger-demo-bucket-xyz-12345/*"
        }
    ]
}
```