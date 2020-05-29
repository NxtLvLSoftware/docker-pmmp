ARG IMAGE
ARG TAG
FROM ${IMAGE:-nxtlvlsoftware/pmmp}:${TAG}

USER root
RUN wget -qO - https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
RUN wget -qO /usr/bin/phpstan https://github.com/phpstan/phpstan/releases/download/0.12.25/phpstan.phar
RUN chmod o+x /usr/bin/phpstan
ADD analyze.php /usr/bin/analyze
ADD phpstan.neon /pocketmine/phpstan.neon
ADD pocketmine.phpstan.neon /pocketmine/pocketmine.phpstan.neon
RUN mkdir /deps
RUN chown 1000:1000 /pocketmine/phpstan.neon /pocketmine/pocketmine.phpstan.neon /deps -R

# install custom rules
RUN mkdir -p /pocketmine/phpstan/rules
RUN wget -qO /pocketmine/phpstan/rules/DisallowEnumComparisonRule.php https://raw.githubusercontent.com/pmmp/PocketMine-MP/4014f9a4f2426b358288ce96386b8d73db760512/tests/phpstan/rules/DisallowEnumComparisonRule.php
ADD config/pm4-enum.phpstan.neon /pocketmine/phpstan/rules/pm4-enums.phpstan.neon
RUN chown 1000:1000 \
	/pocketmine/phpstan/rules/DisallowEnumComparisonRule.php \
	/pocketmine/phpstan/rules/pm4-enums.phpstan.neon

ENV PHPSTAN_CONFIG /pocketmine/phpstan.neon
ENTRYPOINT ["analyze"]
CMD []