FROM archlinux:latest

RUN pacman -Syu --needed --noconfirm sudo
RUN useradd user --system --shell /bin/bash --create-home --home-dir /var/user
RUN passwd --lock user
RUN echo "user ALL=(ALL) NOPASSWD: /usr/bin/pacman" > /etc/sudoers.d/allow_user_to_pacman
RUN echo "root ALL=(ALL) CWD=* ALL" > /etc/sudoers.d/permissive_root_Chdir_Spec

RUN pacman -Syu --needed --noprogressbar --noconfirm \
        base-devel \
        git \
        gcc \
        ffms2 \
        vapoursynth \
        vapoursynth-plugin-bestsource \
        vapoursynth-plugin-mvtools \
        python-pip \
        vim \
        wget && \
    pacman -Sc --noconfirm

USER user
WORKDIR /tmp
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
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
    vapoursynth-plugin-eedi3m-git \
    vapoursynth-plugin-continuityfixer-git \
    vapoursynth-plugin-d2vsource-git \
    vapoursynth-plugin-subtext-git \
    vapoursynth-plugin-imwri-git \
    vapoursynth-plugin-misc-git \
    vapoursynth-plugin-ocr-git \
    vapoursynth-plugin-vivtc-git \
    vapoursynth-plugin-lsmashsource-git && \
    yay -Sc --noconfirm

USER root

RUN pip install --no-cache-dir --upgrade pip --break-system-packages && \
    pip install --no-cache-dir --upgrade yuuno setuptools --break-system-packages

# Hack to fix warning when seeking in %%vspreview w/ R58.                                                                                                                                                                                                                        
# It's specific to both the line and pattern to hopefully avoid breaking anything in future versions.                                                                                                                                                                             
RUN sed -i '223 s/prefer_props=self.extension.prefer_props.*//' /usr/lib64/python3.12/site-packages/yuuno/vs/clip.py
WORKDIR /
EXPOSE 8888
CMD ["jupyter", "lab", "--allow-root", "--port=8888", "--no-browser", "--ip=0.0.0.0"]
