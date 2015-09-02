{% from 'miniconda/map.jinja' import miniconda with context %}

{% set miniconda_download_path = salt.pillar.get('miniconda:download_path', '/tmp') %}
{% set miniconda_install_path = salt.pillar.get('miniconda:install_path', '/usr/local/bin/miniconda') %}
{% set miniconda_url = {
    'x86_64': 'http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh',
    'i686': 'http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh',
}.get(grains.cpuarch) %}


Download miniconda installer:
  cmd.run:
    - name: wget {{ miniconda_url }} -O {{ miniconda_download_path }}/miniconda.sh
    - unless: test -f {{ miniconda_install_path }}/bin/conda


Ensure miniconda is installed:
  cmd.run:
    - name: bash {{ miniconda_download_path }}/miniconda.sh -b -p {{ miniconda_install_path }}
    - unless: test -f {{ miniconda_install_path }}/bin/conda


Ensure miniconda PATH is added to every profile:
  file.managed:
    - name: {{ miniconda.lookup.profile_dir }}/miniconda.sh
    - source: salt://miniconda-formula/miniconda/files/miniconda.sh
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      install_path: {{ miniconda_install_path }}


Ensure PIP is installed:
  cmd.run:
    - name: {{ miniconda_install_path }}/bin/conda install --yes pip
    - unless: test -f {{ miniconda_install_path }}/bin/pip