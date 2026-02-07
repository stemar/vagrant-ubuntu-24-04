echo '==> Updating Ubuntu repositories'

apt-get -q=2 update --fix-missing

apt-get -q=2 install --reinstall tzdata &>/dev/null
timedatectl set-timezone $TIMEZONE

echo '==> Setting '$(timedatectl show | grep Timezone)

echo '==> Installing Linux tools'

cp /vagrant/config/bash_aliases /home/vagrant/.bash_aliases
chown vagrant:vagrant /home/vagrant/.bash_aliases
apt-get -q=2 install software-properties-common apt-transport-https bash-completion curl tree zip unzip pv whois &>/dev/null

echo '==> Installing Git'

apt-get -q=2 install git &>/dev/null

echo '==> Installing Apache'

apt-get -q=2 install apache2 apache2-utils &>/dev/null
apt-get -q=2 update
cp /vagrant/config/localhost.conf /etc/apache2/conf-available/localhost.conf
cp /vagrant/config/virtualhost.conf /etc/apache2/sites-available/virtualhost.conf
sed -i 's|GUEST_SYNCED_FOLDER|'$GUEST_SYNCED_FOLDER'|' /etc/apache2/sites-available/virtualhost.conf
sed -i 's|HOST_HTTP_PORT|'$HOST_HTTP_PORT'|' /etc/apache2/sites-available/virtualhost.conf
a2enconf localhost &>/dev/null
a2enmod rewrite vhost_alias &>/dev/null
a2ensite virtualhost &>/dev/null

echo '==> Setting MariaDB 10.11 repository'

mkdir -p /etc/apt/keyrings
curl -sSLo /etc/apt/keyrings/mariadb-keyring.pgp https://mariadb.org/mariadb_release_signing_key.pgp
cp /vagrant/config/mariadb.sources /etc/apt/sources.list.d/mariadb.sources
apt-get -q=2 update

echo '==> Installing MariaDB'

DEBIAN_FRONTEND=noninteractive apt-get -q=2 install mariadb-server &>/dev/null

echo '==> Setting PHP 8.3 repository'

add-apt-repository -y ppa:ondrej/php &>/dev/null
apt-get -q=2 update

echo '==> Installing PHP'

apt-get -q=2 install php8.3 libapache2-mod-php8.3 libphp8.3-embed \
    php8.3-bcmath php8.3-bz2 php8.3-cli php8.3-curl php8.3-fpm php8.3-gd php8.3-imap php8.3-intl \
    php8.3-mbstring php8.3-mysql php8.3-mysqlnd php8.3-opcache php8.3-pgsql php8.3-pspell \
    php8.3-soap php8.3-sqlite3 php8.3-tidy php8.3-xdebug php8.3-xml php8.3-xmlrpc php8.3-yaml php8.3-zip &>/dev/null
a2dismod mpm_event &>/dev/null
a2enmod mpm_prefork &>/dev/null
a2enmod php8.3 &>/dev/null
sed -i 's|PHP_VERSION|8\.3|' /etc/apache2/sites-available/virtualhost.conf
cp /vagrant/config/php.ini /var/www/php.ini

echo '==> Installing Adminer'

if [ ! -d /usr/share/adminer ]; then
    mkdir -p /usr/share/adminer/adminer-plugins
    curl -LsS https://www.adminer.org/latest-en.php -o /usr/share/adminer/latest-en.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/plugins/login-password-less.php -o /usr/share/adminer/adminer-plugins/login-password-less.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/plugins/dump-json.php -o /usr/share/adminer/adminer-plugins/dump-json.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/plugins/pretty-json-column.php -o /usr/share/adminer/adminer-plugins/pretty-json-column.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/designs/lavender-light/adminer.css -o /usr/share/adminer/adminer.css
fi
cp /vagrant/config/adminer.php /usr/share/adminer/adminer.php
cp /vagrant/config/adminer-plugins.php /usr/share/adminer/adminer-plugins.php
cp /vagrant/config/adminer.conf /etc/apache2/conf-available/adminer.conf
sed -i 's|HOST_HTTP_PORT|'$HOST_HTTP_PORT'|' /etc/apache2/conf-available/adminer.conf
a2enconf adminer &>/dev/null

echo '==> Installing Ruby & irb'

apt-get -q=2 install ruby-full &>/dev/null

echo '==> Starting Apache'

apache2ctl configtest
service apache2 restart

echo '==> Starting MariaDB'

service mariadb restart
mariadb-admin -u root password ""

echo '==> Cleaning apt cache'

apt-get -q=2 autoclean
apt-get -q=2 autoremove

echo
echo '==> Stack versions <=='

lsb_release -d | cut -f 2
openssl version
curl --version | head -n1 | cut -d '(' -f 1
git --version
apache2 -v | head -n1 | cut -d ' ' -f 3
mariadb -V
php -v | head -n1
python3 --version
ruby -v
