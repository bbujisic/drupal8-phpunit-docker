FROM php:7.2-cli-stretch

RUN apt-get update

# Install common utilities and php-gd.
RUN apt-get install -y \
	git \
	ssh-client \
	wget \
	unzip \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
	&& docker-php-ext-install -j$(nproc) iconv \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd

# Install Composer.
ADD install-composer.sh .
RUN bash ./install-composer.sh

# Ensure PHP is available in /usr/bin/php.
# The shebang "#!/usr/bin/env php", used in Composer/Drush, seems to need this.
RUN ln -s /usr/local/bin/php /usr/bin/php

# Install php.ini.
COPY files/usr/local/etc/php/php.ini /usr/local/etc/php/php.ini

# Install the Platform.sh CLI
ADD install-cli.sh .
RUN bash ./install-cli.sh

# Install Drupal tools
ADD install-php-tools.sh .
RUN bash ./install-php-tools.sh

ENV PATH "/root/.composer/vendor/bin:${PATH}"
RUN echo $PATH

RUN phpcs --config-set installed_paths ~/.composer/vendor/drupal/coder/coder_sniffer