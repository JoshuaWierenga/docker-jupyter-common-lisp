FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update; \
    apt-get upgrade; \
    apt-get install -y --no-install-recommends \
          libev-dev \
          python3-pip \
          python3-dev \
          libczmq-dev \
          curl \ 
          make \
          build-essential; \
    \
    tmpdir=$(mktemp -d); \
    cd "$tmpdir" || exit; \
    curl -s https://api.github.com/repos/roswell/roswell/releases/latest | grep "browser_download_url.*amd64\.deb" | cut -d : -f 2,3 | tr -d \" | xargs curl -L --output roswell.deb; \
    dpkg -i roswell.deb; \
    cd || exit; \
    rm -rf "$tmpdir"; \
    \
    pip3 install --upgrade pip; \
    pip3 install jupyter; \
    \
    useradd -mp "$(openssl passwd -crypt jupyter)" jupyter; \
    usermod -s /bin/bash jupyter;
USER jupyter
RUN ros install common-lisp-jupyter; \
    echo 'export PATH=$PATH:~/.roswell/bin' >> ~/.bashrc; \
    jupyter notebook --generate-config; \
    echo c.NotebookApp.ip = \'*\' >> ~/.jupyter/jupyter_notebook_config.py; \
    echo c.NotebookApp.open_browser = False >> ~/.jupyter/jupyter_notebook_config.py; \
    echo c.NotebookApp.port = 8888 >> ~/.jupyter/jupyter_notebook_config.py;
CMD echo "$jupyterPassword"; \
    hashed=$(echo $jupyterPassword | python3 -c 'from notebook.auth import passwd;print(passwd(input()))'); \
    echo "$hashed;" \
    echo c.NotebookApp.password = u\'"$hashed"\' >> ~/.jupyter/jupyter_notebook_config.py; \
    jupyter notebook;
