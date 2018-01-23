mariadb-server:
  pkg.installed:
    - names:
      - mariadb-server
      - mariadb
      - MySQL-python.x86_64

mariadb_running:
  service.running:
    - name: mariadb

wordpress:
  mysql_database.present

wordpresser:
  mysql_user.present:
    - host: localhost
    - password: '{{ salt['grains.get_or_set_hash']('some_mysql_user', 20) }}'

frank_exampledb:
   mysql_grants.present:
    - grant: all privileges
    - database: wordpress.*
    - user: wordpresser
    - host: localhost
