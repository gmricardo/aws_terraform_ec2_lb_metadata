# aws_terraform_ec2_lb_metadata
Proyecto en AWS con Terraform que despliega dos instancias EC2 detrás de un Load Balancer. Cada instancia ejecuta una app sencilla que muestra metadatos de la máquina (IP y otros). Ejemplo práctico para aprender aprovisionamiento, balanceo y despliegue básico en la nube.

# AWS EC2 + Load Balancer + Metadata Demo

Este proyecto despliega una infraestructura en AWS usando Terraform que incluye:

- **2 instancias EC2** con Amazon Linux 2, servidor Apache (`httpd`) instalado y una página personalizada que muestra la IP privada y tu presentación profesional.
- **Balanceador de carga (ALB)** que distribuye el tráfico HTTP entre ambas instancias.
- **Security Group** que permite acceso HTTP (80) desde cualquier IP y SSH (22) solo desde tu IP.
- **Acceso a la metadata de la instancia usando IMDSv2** para mostrar la IP privada en la web.
- **Plantilla HTML** centralizada para la presentación en ambas instancias.

## Estructura

- `main.tf`: Código principal de Terraform con todos los recursos.
- `presentation.html.tpl`: Plantilla HTML con tu presentación profesional.
- `variables.tf` (opcional): Variables reutilizables.
- `outputs.tf` (opcional): Outputs útiles como IPs públicas.

## Requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Key Pair existente en AWS (`keyPairGmricardo3`)
- Permisos para crear recursos en AWS

## Despliegue

1. Clona el repositorio y entra en la carpeta del proyecto.
2. Inicializa Terraform:
   ```bash
   terraform init
   ```
3. Revisa el plan:
   ```bash
   terraform plan
   ```
4. Aplica la infraestructura:
   ```bash
   terraform apply
   ```
5. Accede al Load Balancer en el navegador para ver la página personalizada.

## Recursos creados

- **VPC y Subnets**: Usa la VPC y subnets por defecto.
- **Security Group**: Permite HTTP (80) y SSH (22) solo desde tu IP.
- **EC2 Instances**: Instalan Apache y publican una página con tu presentación y la IP privada.
- **Application Load Balancer**: Balancea tráfico entre ambas instancias.
- **Target Group y Attachments**: Asocia las instancias al ALB.

## Personalización

- Edita `presentation.html.tpl` para cambiar la presentación.
- Cambia el nombre del key pair en `main.tf` si usas otro.

## Autor

**Ricardo Garzón Medina**  
Ingeniero en Seguridad Informática | Cloud & DevSecOps

---

*Infraestructura automatizada con Terraform. Seguridad y buenas prácticas desde el inicio.*