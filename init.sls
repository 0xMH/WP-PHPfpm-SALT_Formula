{% from "nginx/map.jinja" import nginx, parent_dict, php_source with context %}



Repo:
  pkg.installed:
    - name: {{ nginx.repo }}

# Ensure the Development Tools are installed

{{ nginx.InstallationGroup }}:
  pkg.group_installed

# Install OptionalDependencies
{% for pkg in 'perl', 'perl-devel', 'perl-ExtUtils-Embed', 'libxslt', 'libxslt-devel', 'libxml2', 'libxml2-devel', 'gd', 'gd-devel', 'GeoIP', 'GeoIP-devel' %}
{{ pkg }}:
  pkg.installed
{% endfor %}

# Ensure the the NGINX dependencies'& latest mainline version of NGINX source code source code are present
{% for dict_item in parent_dict %}
{% for key, value in dict_item.items() %}
{{ key }}:
  cmd.run:
    - name: |
          cd /tmp
          curl -L  {{ value }} -o {{ key }}
          tar xzf {{ key }}
          rm -rf {{ key }}
    - creates: /tmp/{{ key }}
{% endfor %}
{% endfor %}


AddGroup:
  group.present:
    - name: {{ nginx.group }}
    - system: True
AddUser:
  user.present:
    - name: {{ nginx.user }}
    - gid: {{ nginx.group }}
    - system: True



# bash script for "./configure" Nginx.
/tmp/nginx-1.13.2/nginx.sh:
  file.managed:
    - source: salt://nginx/files/nginx/nginx.sh.jinja
    - user: root
    - group: root
    - mode: 744
    - template: jinja


Nginx-installation:
 cmd.run:
   - name: |
       cd /tmp/nginx-1.13.2
       sh nginx.sh
       make
       make install
   - runas: root


# create client_temp to sovle "[emerg] mkdir() "/var/cache/nginx/client_temp" failed"
/var/cache/nginx/client_temp:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

# ngnix websharing dir
/usr/share/nginx/html/:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True

# configure nginx
/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/files/nginx/nginx.conf.jinja
    - user: nginx
    - group: nginx
    - mode: 644
    - template: jinja


# systemd service.
/usr/lib/systemd/system/nginx.service:
  file.managed:
    - source: salt://nginx/files/nginx/systemd_unit.jinja
    - user: root
    - group: root
    - mode: 744
    - template: jinja

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /usr/lib/systemd/system/nginx.service


nginx_running:
  service.running:
    - name: nginx
    - watch:
      - file: /usr/lib/systemd/system/nginx.service
      - file : /etc/nginx/nginx.conf

# public:
#   firewalld.present:
#     - ports:
#       - 80/tcp

# saltzone:
#   firewalld.service:
#     - name: saltzone
#     - services:
#       - saltmaster



# http://be2.php.net/get/php-5.6.32.tar.bz2/from/this/mirror
# https://www.vultr.com/docs/how-to-compile-nginx-from-source-on-centos-7
