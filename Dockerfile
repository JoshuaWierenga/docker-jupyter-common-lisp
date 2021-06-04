FROM archlinux:base-devel
#Temporary fix to get around docker issue, https://bugs.archlinux.org/task/69563
RUN patched_glibc=glibc-linux4-2.33-5-x86_64.pkg.tar.zst; \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc"; \
    bsdtar -C / -xvf "$patched_glibc";
RUN pacman -Syu --noconfirm; \
    pacman -S git --noconfirm; \
    \
    useradd -m jupyter; \
    passwd -d jupyter; \
    printf 'jupyter ALL=(ALL) ALL\n' | tee -a /etc/sudoers;
#TODO: Refactor?, this ensures git is in the resulting image but it is not needed post image building
USER jupyter
#TODO: Skip yay and just install roswell directly?
RUN pwd; \
    cd ~; \
    git clone https://aur.archlinux.org/yay.git; \
    cd yay; \
    makepkg -si --noconfirm; \
    yay -S roswell;
    
    
    #TODO: Remove GO!, it was installed by makepkg
    #TODO: Remove yay?
    
    #apt-get install -y --no-install-recommends \
    #    libev-dev \
    #    python3-pip \
    #    python3-dev \
    #    libczmq-dev \
    #    build-essential \
    #    curl \ 
    #    make \
    #    sudo; \
    #\
    #tmpdir=$(mktemp -d); \
    #cd "$tmpdir" || exit 1; \
    #curl -s https://api.github.com/repos/roswell/roswell/releases/latest | grep "browser_download_url.*amd64\.deb" | cut -d : -f 2,3 | tr -d \" | xargs curl -L --output roswell.deb; \
    #dpkg -i roswell.deb; \
    #cd || exit 1; \
    #rm -rf "$tmpdir"; \
    #\
    #pip3 install --upgrade pip; \
    #pip3 install jupyter; \
    #\
    #sudo -u jupyter ros install common-lisp-jupyter; \
    #\
    #export SUDO_FORCE_REMOVE=yes; \
    #apt-get remove -y \
    #    libev-dev \
    #    python3-pip \
    #    build-essential \
    #    sudo; \
    #apt-get autoremove -y; \
    #apt-get clean; \
    #rm -rf /var/lib/apt/lists/*;
#USER jupyter
#RUN jupyter notebook --generate-config; \
#    { \
#        echo c.NotebookApp.ip = \'*\'; \
#        echo c.NotebookApp.open_browser = False; \
#        echo c.NotebookApp.port = 8888; \
#        echo c.NotebookApp.notebook_dir = \'/srv/jupyter/\'; \
#    }>> ~/.jupyter/jupyter_notebook_config.py;
#CMD PATH="$HOME/.roswell/bin:$PATH"; \
#    echo c.NotebookApp.password = u\'"$(echo $jupyterPassword | python3 -c 'from notebook.auth import passwd;print(passwd(input()))')"\' >> ~/.jupyter/jupyter_notebook_config.py; \
#    jupyter notebook;
