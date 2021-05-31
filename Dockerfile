FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; \
    apt-get upgrade; \
    apt install -y --no-install-recommends \
          libev-dev \
          python3-pip \
          python3-dev \
          libczmq-dev; \
    \
    tmpdir=$(mktemp -d); \
    cd "$tmpdir" || exit; \
    curl -s https://api.github.com/repos/roswell/roswell/releases/latest | grep "browser_download_url.*amd64\.deb" | cut -d : -f 2,3 | tr -d \" | xargs curl -L --output roswell.deb; \
    dpkg -i roswell.deb; \
    cd; \
    rm -rf "$tmpdir"; \
    \
    pip3 install --upgrade pip; \
    pip3 install jupyter; \
    \
    useradd -mp "$(openssl passwd -crypt jupyter)" jupyter; \
    usermod -s /bin/bash jupyter; \
    \
    su - jupyter; \
    ros install common-lisp-jupyter; \
    echo 'export PATH=$PATH:~/.roswell/bin' >> ~/.bashrc; \
    jupyter notebook --generate-config \
    { \
      echo "c.NotebookApp.ip = '*' \
    c.NotebookApp.password = u'$(echo $juypterPassword | python3 -c 'from notebook.auth import passwd;print(passwd(input()))')' \
    c.NotebookApp.open_browser = False \
    c.NotebookApp.port = 8888 \
    c.NotebookApp.notebook_dir = '/srv/jupyter/'" \
    } >> ~/.jupyter/jupyter_notebook_config.py;
CMD su - jupyter; \
    jupyter notebook;
