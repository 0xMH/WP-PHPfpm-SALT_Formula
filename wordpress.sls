include:
  - nginx
  - nginx.mysql
  - nginx.php-fpm
  - nginx.csf

# wordpress_dependencies:
#   pkg.installed:
#     - names:
#       - php-gd
#     - require:
#       - nginx_running



wordpress_installation:
  cmd.run:
    - name: |
          cd /tmp
          curl -L http://wordpress.org/latest.tar.gz -o wordpress.tar.gz
          tar xzf wordpress.tar.gz
          rm -rf wordpress.tar.gz
          rsync -avP wordpress/ /usr/share/nginx/html/
          chown -R nginx:nginx /usr/share/nginx/html/*
    - creates: /tmp/wordpress/
/usr/share/nginx/html/wp-config.php:
  file.managed:
    - source: salt://nginx/files/wp-config.jinja
    - user: nginx
    - group: nginx
    - mode: '644'
    - makedirs: True
    - template: jinja
