locals {
  primary_user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<html><body><h1>Primary VPC: ${var.regions.primary}</h1></body></html>" > /var/www/html/index.html
    echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
    EOF

  secondary_user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<html><body><h1>Secondary VPC: ${var.regions.secondary}</h1></body></html>" > /var/www/html/index.html
    echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
    EOF
}
