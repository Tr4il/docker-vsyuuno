FROM archlinux:latest

RUN pacman -Syu --needed --noconfirm sudo
RUN useradd user --system --shell /bin/bash --create-home --home-dir /var/user
RUN passwd --lock user
RUN echo "user ALL=(ALL) NOPASSWD: /usr/bin/pacman" > /etc/sudoers.d/allow_user_to_pacman
RUN echo "root ALL=(ALL) CWD=* ALL" > /etc/sudoers.d/permissive_root_Chdir_Spec

RUN pacman -Syu --needed --noprogressbar --noconfirm base-devel git gcc ffms2 vapoursynth python-pip vim wget vapoursynth-plugin-lsmashsource

USER user
WORKDIR /tmp
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg --noconfirm --noprogressbar -si && \
    yay --afterclean --removemake --save && cd -

WORKDIR /tmp
RUN git clone https://aur.archlinux.org/vapoursynth-plugin-d2vsource-git.git && \
    cd vapoursynth-plugin-d2vsource-git && \
    rm PKGBUILD && \
    wget -O PKGBUILD https://gist.github.com/Tr4il/aa24d59e6bcae33872d3a698a4deb525/raw/0e71d428081dcdc65b76233e55251ad1a0164beb/d2vsource.PKGBUILD && \
    makepkg --noconfirm --noprogressbar -si && \
    yay --afterclean --removemake --save && cd -


# install vapoursynth plugins                                                                                                                                                                                                                                                    
RUN yay -Syu --overwrite "*" --noconfirm --noprogressbar --needed \
    vapoursynth-plugin-removegrain-git \
    vapoursynth-plugin-rekt-git \
    vapoursynth-plugin-remapframes-git \
    vapoursynth-plugin-fillborders-git \
    vapoursynth-plugin-havsfunc-git \
    vapoursynth-plugin-awsmfunc-git \
    vapoursynth-plugin-continuityfixer-git \
#    vapoursynth-plugin-d2vsource-git \
    vapoursynth-plugin-subtext-git \
    vapoursynth-plugin-imwri-git

USER root

RUN pip install --no-cache-dir --upgrade pip \
    pip install --no-cache-dir --upgrade yuuno setuptools --break-system-packages

# Hack to fix warning when seeking in %%vspreview w/ R58.                                                                                                                                                                                                                        
# It's specific to both the line and pattern to hopefully avoid breaking anything in future versions.                                                                                                                                                                             
RUN sed -i '223 s/prefer_props=self.extension.prefer_props.*//' /usr/lib64/python3.11/site-packages/yuuno/vs/clip.py
WORKDIR /
EXPOSE 8888
CMD ["jupyter", "lab", "--allow-root", "--port=8888", "--no-browser", "--ip=0.0.0.0"]