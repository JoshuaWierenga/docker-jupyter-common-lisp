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
    #use this to just do everything as jupyter user and so be able to remove packages after using them
    printf 'jupyter ALL=(ALL) ALL\n' | tee -a /etc/sudoers;
#TODO: Refactor?, this ensures git is in the resulting image but it is not needed post image building
USER jupyter
#TODO: Skip yay and just install roswell directly?
RUN cd ~; \
    git clone https://aur.archlinux.org/yay.git; \
    cd yay; \
    makepkg -si --noconfirm; \
    yes N | yay -S roswell;
    cd ~; \
    rm -rf yay;
    #TODO: Remove GO!, it was installed by makepkg
    #TODO: Remove yay?
USER root
    #pacman -Rcns git yay go; needs to be done in the same layer as pacman -S git --noconfirm, makepkg -si --noconfirm and yay -S roswell 
    #TODO: Check if libev is still required
RUN pacman -S libev python python-pip python-six python-cffi zeromq --noconfirm;
    \
    pip3 install --upgrade pip; \
    pip3 install jupyter; \
    \
    sudo -u jupyter ros install common-lisp-jupyter; \
    \
    # figure out if removing unneeded packages that shipped with arch is worth it
    # remove base-devel? depends on how big it is
    #export SUDO_FORCE_REMOVE=yes; \
    pacman -Rcns libev python-pip --noconfirm; \
    #apt-get remove -y \
    #    sudo; \
    pacman -Syy; \
    yes | pacman -Scc;
    # can the package listings be removed like on ubuntu?
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
