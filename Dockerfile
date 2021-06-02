FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
          python3-pip \
          python3-dev \
          libczmq-dev \
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
    apt-get remove -y \
        python3-pip; \
    apt-get autoremove; \
    apt-get clean;
USER jupyter
RUN sudo apt-get install -y --no-install-recommends \
        libev-dev \
        build-essential; \
    \
    ros install common-lisp-jupyter; \
    jupyter notebook --generate-config; \
    { \
        echo c.NotebookApp.ip = \'*\'; \
        echo c.NotebookApp.open_browser = False; \
        echo c.NotebookApp.port = 8888; \
        echo c.NotebookApp.notebook_dir = \'/srv/jupyter/\'; \
    }>> ~/.jupyter/jupyter_notebook_config.py; \
    \
    apt-get remove -y \
        libev-dev \
        build-essential; \
   apt-get autoremove; \
   apt-get clean;
USER jupyter
CMD PATH="$HOME/.roswell/bin:$PATH"; \
    echo c.NotebookApp.password = u\'"$(echo $jupyterPassword | python3 -c 'from notebook.auth import passwd;print(passwd(input()))')"\' >> ~/.jupyter/jupyter_notebook_config.py; \
    jupyter notebook;
