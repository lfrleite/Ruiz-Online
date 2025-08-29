# Atualizando o sistema e instalando pacotes necessários
```js
apt update && apt upgrade && apt dist-upgrade && apt full-upgrade -y
```
---
```js
apt install -y apache2 php php-common php-mysql libapache2-mod-php \
php-gd php-curl php-json php-xmlrpc php-intl php-bcmath php-zip php-apcu \
php-mbstring php-fileinfo php-xml php-soap wget curl php-bz2 php-ldap apache2 apache2-utils apache2-bin apache2-data php php-cli php-common \
php-mysql php-opcache php-readline php-common php-bcmath php-curl php-intl php-mbstring \
php-xml php-zip php-soap php-imagick php-json libapache2-mod-php libapr1 libaprutil1-ldap \
libapache2-mod-php libaprutil1 libaprutil1-dbd-sqlite3 php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell \
php-mysql php-tidy php-xmlrpc php-mbstring php-ldap php-cas php-apcu php-json php-xml php-cli \
libapache2-mod-php xmlrpc-api-utils xz-utils bzip2 unzip curl php-soap php-common php-bcmath \
php-zip php-bz2
```

# Configurando o PHP
```js
PHP_INI="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')/apache2/php.ini"
sed -i 's/^session.cookie_httponly =/session.cookie_httponly = on/g' "$PHP_INI"
```

# Baixando a última versão do GLPI
```js
GLPI_VERSION=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://github.com/glpi-project/glpi/releases/download/"$GLPI_VERSION"/glpi-"$GLPI_VERSION".tgz
```

# Extraindo e movendo o GLPI para o diretório do Apache
```js
tar xvf glpi-"$GLPI_VERSION".tgz
```
```js
rm -rf /var/www/html
```
```js
mv glpi /var/www/html
```
```js
chown -R www-data:www-data /var/www/html
```
```js
chmod -R u+rw /var/www/html
```

# Reinicialização do servidor web para buscar a nova configuração
```js
systemctl restart apache2
```

# Criando um arquivo na pasta "/etc/apache2/conf-available" para configuração do GLPI no APACHE
```js
vim /etc/apache2/conf-available/glpi.conf
```

# Adicionando as informações abaixo dentro do arquivo "glpi.conf"
```js
<VirtualHost *:80>
    # Remover o comentário de ServerName quando tiver o FQDN já com SSL
    ### ServerName glpi.localhost

    DocumentRoot /var/www/html/public

    # If you want to place GLPI in a subfolder of your site (e.g. your virtual host is serving multiple applications),
    # you can use an Alias directive. If you do this, the DocumentRoot directive MUST NOT target the GLPI directory itself.
    # Alias "/glpi" "/var/www/glpi/public"

    <Directory /var/www/html/public>
        Require all granted

        RewriteEngine On

        # Ensure authorization headers are passed to PHP.
        # Some Apache configurations may filter them and break usage of API, CalDAV, ...
        RewriteCond %{HTTP:Authorization} ^(.+)$
        RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

        AllowOverride All
        RewriteEngine On

        # Redirect all requests to GLPI router, unless file exists.
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>
</VirtualHost>
```

# Habilitação do módulo rewrite no apache
```js
a2enmod rewrite
```

# Habilitação da configuração previamente criada
```js
a2enconf glpi.conf
```
# Reinicialização do servidor web para buscar a nova configuração
service apache2 restart

# Ao final da instalação, realize a exclusão do arquivo install.php
rm /var/www/html/install/install.php
