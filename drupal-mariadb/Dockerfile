FROM mariadb:10.2

ADD ./my_config.cnf /etc/mysql/conf.d/
RUN chmod 0644 /etc/mysql/conf.d/my_config.cnf
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
