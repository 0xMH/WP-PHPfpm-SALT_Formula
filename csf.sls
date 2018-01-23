{% for pkg in 'perl-libwww-perl.noarch', 'perl-Time-HiRes' %}
{{ pkg }}:
  pkg.installed
{% endfor %}

csf_Installation:
  cmd.run:
    - name: |
          cd /tmp
          curl -L  https://download.configserver.com/csf.tgz -o csf.tgz
          tar xzf csf.tgz
          rm -rf csf.tgz
          cd csf
          sh install.sh


    # - creates: /tmp/csf
stop_firewalld:
  service.dead:
    - name: firewalld

disable_firewalld:
  service.disabled:
    - name: firewalld

/etc/csf/csf.conf:
  file.replace:
    - pattern: |
        \bTESTING\b = "1"
    - repl: TESTING = "0"
    - bufsize: file

csf_running:
  service.running:
    - names:
      - csf
      - lfd

csf_enabled:
  service.enabled:
    - names:
      - csf
      - lfd
