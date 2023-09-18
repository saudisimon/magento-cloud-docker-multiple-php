FROM ubuntu:focal

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p /home/public_html /run/php /var/lib/php/session &&\
	groupadd -g 1000 nginx && useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx &&\
	chown -R nginx:nginx /home/public_html/	&&\
	chown -R nginx:nginx /var/lib/php/

WORKDIR /home/public_html

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update -y
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y software-properties-common
RUN export DEBIAN_FRONTEND=noninteractive && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update -y
RUN export DEBIAN_FRONTEND=noninteractive &&\
	apt-get -y install php8.2 php8.2-dev php8.2-apcu php8.2-fpm php8.2-common php8.2-gd php8.2-intl php8.2-soap php8.2-opcache php8.2-xml php8.2-mysql php8.2-mbstring php8.2-bcmath php8.2-curl php8.2-zip php8.2-xdebug

RUN update-alternatives --set php /usr/bin/php8.2 \
	&& update-alternatives --set phar /usr/bin/phar8.2 \
	&& update-alternatives --set phar.phar /usr/bin/phar.phar8.2 \
	&& update-alternatives --set phpize /usr/bin/phpize8.2 \
	&& update-alternatives --set php-config /usr/bin/php-config8.2
	

RUN apt-get update && apt-get install -y nano \
	git \
	htop \
	dnsutils \
	ssmtp \
	mailutils \
    --no-install-recommends \
    && echo "mailhub=mailhog:1025" >> /etc/ssmtp/ssmtp.conf
	
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y curl git sudo apt-utils vim zip unzip
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -y curl net-tools lsof

RUN curl https://getcomposer.org/download/2.1.12/composer.phar --output /usr/bin/composer && chmod +x /usr/bin/composer
RUN curl https://files.magerun.net/n98-magerun2.phar --output /usr/bin/n98-magerun2.phar && chmod +x /usr/bin/n98-magerun2.phar

RUN export DEBIAN_FRONTEND=noninteractive \ 
	&& curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh \
    && sudo bash nodesource_setup.sh \
    && apt-get install -y nodejs \
    && apt-get update \
    && npm install -g grunt-cli \
    && npm i -g yarn

RUN su - nginx -c "touch /home/nginx/.bash_profile"
RUN su - nginx -c "curl https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
RUN chmod +x /home/nginx/.nvm/nvm.sh
RUN su - nginx -c "echo '[ -s /home/nginx/.nvm/nvm.sh ] && . /home/nginx/.nvm/nvm.sh # This loads NVM' > .profile"
RUN unlink /etc/php/8.2/cli/conf.d/20-xdebug.ini \
	&& unlink /etc/php/8.2/fpm/conf.d/20-xdebug.ini

RUN pecl channel-update pecl.php.net
RUN export DEBIAN_FRONTEND=noninteractive\ 
 		&& apt-get install libmcrypt-dev -y
RUN pecl install mcrypt
RUN pecl install -f xdebug-3.1.5 \ 
	&& touch /var/log/xdebug_remote.log \
	&& chmod 777 /var/log/xdebug_remote.log
	

# Improve shell prompt: nginx@/home/public_html
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo 'function now() { date +%H:%M:%S; }\n\' | tee --append /etc/bash.bashrc /home/nginx/.bashrc
RUN printf 'function php_version() { php -r "echo \"PHP:\". PHP_VERSION;"; }\n\
function parse_git_branch() { git branch 2> /dev/null | sed -e '\''/^[^*]/d'\'' -e '\''s/* \(.*\)/ (\\1)/'\''; }\n\
function nonzero_return() { RETVAL=$? ; [ $RETVAL -ne 0 ] && echo " [exit code: $RETVAL]" ; }\n\
function proxy_preprod_status() { netstat -ltn | grep 3128 >/dev/null && echo " \e[35m[proxy:preprod]\e[m"; return 0; }\n\
function proxy_consumer_db_status() { netstat -ltn | grep 8123 >/dev/null && echo " \e[35m[proxy:consumer_db]\e[m"; return 0; }\n\
PS1="\[\e[32m\]\u\[\e[m\]\[\e[34m\]@\[\e[m\]\[\e[36m\]\w\[\e[m\] \[\e[34m\]\$(now)\[\e[m\]\[\e[33m\]\`parse_git_branch\`\[\e[m\]\[\e[m\]\[\e[31m\]\`nonzero_return\`\[\e[m\]\`proxy_preprod_status\`\`proxy_consumer_db_status\`\n➞ "\n\
. /home/nginx/.bash_aliases\n' | tee --append /etc/bash.bashrc /home/nginx/.bashrc
ARG ACCOUNT_USERNAME

RUN printf '\nif [ -n \"\$SSH_CONNECTION\" ]; then\n\
    echo -e "*************************************************\n*\t\t\t\t\t\t*\n* Welcome \e[32m'$ACCOUNT_USERNAME'\e[m Have a nice day!\t\t*\n*\t\t\t\t\t\t*\n*************************************************"\n\
fi\n' | tee /home/nginx/.bashrc

RUN curl -L https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 --output /usr/local/bin/mhsendmail \
	&& chmod +x /usr/local/bin/mhsendmail

RUN mkdir /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer

RUN echo "nginx ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nginx

ENTRYPOINT ["/tini", "--", "/usr/local/bin/custom-entrypoint.sh"]
CMD ["/usr/sbin/php-fpm8.2", "-F", "-O", "--fpm-config", "/etc/php/8.2/fpm/php-fpm.conf"]
