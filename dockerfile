FROM frolvlad/alpine-glibc:alpine-3.8
# baseado em: https://github.com/frol/docker-alpine-miniconda3
# exemplo base para criar uma imagem com spacy  
# para servir modelos em python ou treinamentos de modelos 
# para gerar a imagem base: docker build -t spacybase . 

ENV CONDA_DIR="/opt/conda"
ENV PATH="$CONDA_DIR/bin:$PATH"

# Install conda
RUN CONDA_VERSION="4.5.4" && \
    CONDA_MD5_CHECKSUM="a946ea1d0c4a642ddf0c3a26a18bb16d" && \
    \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates bash && \
    \
    mkdir -p "$CONDA_DIR" && \
    wget "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh" -O miniconda.sh && \
    echo "$CONDA_MD5_CHECKSUM  miniconda.sh" | md5sum -c && \
    bash miniconda.sh -f -b -p "$CONDA_DIR" && \
    echo "export PATH=$CONDA_DIR/bin:\$PATH" > /etc/profile.d/conda.sh && \
    rm miniconda.sh && \
    \
    conda update --all --yes && \
    conda config --set auto_update_conda False && \
    rm -r "$CONDA_DIR/pkgs/" && \
    \
    apk del --purge .build-dependencies && \
    \
    mkdir -p "$CONDA_DIR/locks" && \
    chmod 777 "$CONDA_DIR/locks"

RUN apk add --no-cache tzdata
ENV TZ=America/Sao_Paulo
	
RUN	pip install --upgrade pip setuptools && \ 
	pip install --no-cache-dir nltk && \ 
	pip install --no-cache-dir flask && \
	pip install --no-cache-dir sklearn && \ 
	python -c "from nltk import download as nldw; nldw('stopwords'); print('Stopwords baixadas')"
	
RUN apk update && \ 
    apk upgrade && \ 
    apk add --no-cache libstdc++ && \ 
    apk add --no-cache --virtual=build_deps g++ gfortran && \ 
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \ 
    pip install --no-cache-dir spacy && \ 
	python -m spacy download pt &&\ 
    rm /usr/include/xlocale.h && \ 
    apk del build_deps 

RUN python -c 'import platform; print(platform.architecture())'	
