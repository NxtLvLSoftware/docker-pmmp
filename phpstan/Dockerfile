ARG IMAGE
ARG TAG
FROM ${IMAGE:-nxtlvlsoftware/pmmp}:${TAG}

USER root
RUN wget -qO - https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
RUN wget -qO /usr/bin/phpstan https://github.com/phpstan/phpstan/releases/download/0.12.9/phpstan.phar
RUN chmod o+x /usr/bin/phpstan
ADD analyze.php /usr/bin/analyze
ADD phpstan.neon /pocketmine/phpstan.neon
ADD pocketmine.phpstan.neon /pocketmine/pocketmine.phpstan.neon
RUN mkdir /deps
RUN chown 1000:1000 /pocketmine/phpstan.neon /pocketmine/pocketmine.phpstan.neon /deps -R

ENV PHPSTAN_CONFIG /pocketmine/phpstan.neon
ENTRYPOINT ["analyze"]
CMD []