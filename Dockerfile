FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
        libev-dev \
        python3-pip \
        python3-dev \
        libczmq-dev \
        build-essential \
        curl \ 
        make \
        sudo; \
    \
    tmpdir=$(mktemp -d); \
    cd "$tmpdir" || exit 1; \
    curl -s https://api.github.com/repos/roswell/roswell/releases/latest | grep "browser_download_url.*amd64\.deb" | cut -d : -f 2,3 | tr -d \" | xargs curl -L --output roswell.deb; \
    dpkg -i roswell.deb; \
    cd || exit 1; \
    rm -rf "$tmpdir"; \
    \
    pip3 install --upgrade pip; \
    pip3 install jupyter; \
    \
    useradd -mp "$(openssl passwd -crypt jupyter)" jupyter; \
    \
    sudo -u jupyter ros install common-lisp-jupyter; \
    \
    export SUDO_FORCE_REMOVE=yes; \
    apt-get remove -y \
        libev-dev \
        python3-pip \
        build-essential \
        sudo; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;
USER jupyter
RUN jupyter notebook --generate-config; \
    { \
        echo c.NotebookApp.ip = \'*\'; \
        echo c.NotebookApp.open_browser = False; \
        echo c.NotebookApp.port = 8888; \
        echo c.NotebookApp.notebook_dir = \'/srv/jupyter/\'; \
    }>> ~/.jupyter/jupyter_notebook_config.py;
CMD PATH="$HOME/.roswell/bin:$PATH"; \
    echo c.NotebookApp.password = u\'"$(echo $jupyterPassword | python3 -c 'from notebook.auth import passwd;print(passwd(input()))')"\' >> ~/.jupyter/jupyter_notebook_config.py; \
    jupyter notebook;
