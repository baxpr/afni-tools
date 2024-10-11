FROM afni/afni_make_build:AFNI_24.2.06

RUN mkdir /opt/afni/install/atlases && \
    cd /opt/afni/install/atlases && \
    curl -o afni_atlases_dist.tgz https://afni.nimh.nih.gov/pub/dist/atlases/afni_atlases_dist.tgz && \
    tar -zxf afni_atlases_dist.tgz && \
    rm -f afni_atlases_dist.tgz

ENV AFNI_PLUGINPATH=/opt/afni/install/atlases/afni_atlases_dist
