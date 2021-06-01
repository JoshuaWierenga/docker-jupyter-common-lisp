# docker-jupyter-common-lisp

This was mostly made for my use but I couldn't figure out how to get docker containers into unraid without publishing it so here is a container that installs jupyter notebooks with the common-lisp-jupyter kernel.

This container should be run behind a reverse proxy with a https cert for security.

To use this with unraid like I do, https://github.com/JoshuaWierenga/unraid-docker-templates/tree/main/docker-template should be added to the "Template repositories:" section of the docker tab. Then this container should appear in the list of templates as "jupyterlisp".
