{% from "nginx/map.jinja" import php_source, php_dep with context %}



{% for key, value in php_source.items() %}
{{ key }}:
  cmd.run:
    - name: |
          cd /tmp
          curl -L  {{ value }} -o {{ key }}
          tar xzf {{ key }}
          rm -rf {{ key }}
    - creates: /tmp/{{ key }}
{% endfor %}

# Ensure the directory where we are going to put PHP is made
/usr/local/php7:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% for pkg in php_dep %}
{{ pkg }}:
  pkg.installed
{% endfor %}


# https://shaunfreeman.name/compiling-php-7-on-centos/


/tmp/php-7.1.11/php.sh:
  file.managed:
    - source: salt://nginx/files/php-fpm/php.sh.jinja
    - user: root
    - group: root
    - mode: 744
    - template: jinja


PHP-installation:
 cmd.run:
   - name: |
       cd /tmp/php-7.1.11
       sh php.sh
       make
       make install
   - runas: root

/usr/local/php7/etc/conf.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/usr/local/php7/lib/php.ini:
  file.managed:
    - source:
      - /tmp/php-7.1.11/php.ini-production
    - user: root
    - group: root
    - mode: '644'
    - makedirs: True


/usr/local/php7/etc/php-fpm.d/www.conf:
  file.managed:
    - source: salt://nginx/files/php-fpm/fpm-pool.conf.jinja
    - user: root
    - group: root
    - mode: '644'
    - makedirs: True


/usr/local/php7/etc/php-fpm.conf:
  file.managed:
    - source:
      - /tmp/php-7.1.11/sapi/fpm/php-fpm.conf
    - user: root
    - group: root
    - mode: '644'
    - makedirs: True



/usr/lib/systemd/system/php-fpm.service:
  file.managed:
    - source: salt://nginx/files/php-fpm/php-fpm-Systemd.jinja
    - user: root
    - group: root
    - mode: 744
    - template: jinja

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /usr/lib/systemd/system/php-fpm.service


php-fpm_running:
  service.running:
    - name: php-fpm
    - watch:
      - module: /usr/lib/systemd/system/php-fpm.service



/usr/local/php7/etc/conf.d/modules.ini:
  file.managed:
    - contents: |
        zend_extension=opcache.so

/usr/sbin/php-fpm:
  file.symlink:
    - target: /usr/local/php7/sbin/php-fpm


# https://shaunfreeman.name/compiling-php-7-on-centos/

# TO-DO:
#   - mkdir -p /usr/share/nginx/html/
