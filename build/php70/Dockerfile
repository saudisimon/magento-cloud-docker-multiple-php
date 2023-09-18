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
	apt-get -y install php7.0 php7.0-dev php7.0-apcu php7.0-fpm php7.0-common php7.0-gd php7.0-intl php7.0-soap php7.0-opcache php7.0-xml php7.0-mysql php7.0-mbstring php7.0-bcmath php7.0-json php7.0-curl php7.0-zip

RUN update-alternatives --set php /usr/bin/php7.0 \
	&& update-alternatives --set phar /usr/bin/phar7.0 \
	&& update-alternatives --set phar.phar /usr/bin/phar.phar7.0 \
	&& update-alternatives --set phpize /usr/bin/phpize7.0 \
	&& update-alternatives --set php-config /usr/bin/php-config7.0
	
RUN apt-get update && apt-get install -y nano \
	git \
	htop \
	dnsutils \
	ssmtp \
	mailutils \
    --no-install-recommends \
    && echo "mailhub=mailhog:1025" >> /etc/ssmtp/ssmtp.conf
    
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y curl git sudo apt-utils vim zip unzip net-tools lsof
RUN dpkg-reconfigure -f noninteractive tzdata

RUN curl https://getcomposer.org/download/1.10.19/composer.phar --output /usr/bin/composer && chmod +x /usr/bin/composer
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

RUN pecl channel-update pecl.php.net
RUN export DEBIAN_FRONTEND=noninteractive\ 
		&& apt-get install libmcrypt-dev php7.0-mcrypt -y
# RUN pecl install mcrypt
RUN pecl install -f xdebug-2.7.2 \ 
	&& touch /var/log/xdebug_remote.log \
	&& chmod 777 /var/log/xdebug_remote.log


RUN export PATH=$PATH:/usr/local/bin/
RUN curl -L https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 --output /usr/local/bin/mhsendmail \
	&& chmod +x /usr/local/bin/mhsendmail
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

RUN mkdir /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer

RUN echo "nginx ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nginx

ENTRYPOINT ["/tini", "--", "/usr/local/bin/custom-entrypoint.sh"]
CMD ["/usr/sbin/php-fpm7.0", "-F", "-O", "--fpm-config", "/etc/php/7.0/fpm/php-fpm.conf"]
