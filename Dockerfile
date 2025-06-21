FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04
# FROM pytorch/pytorch:1.13.1-cuda11.8-cudnn8-runtime


RUN apt-get update
RUN apt-get install -y locales
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8
RUN export LANG=en_US.utf8

RUN apt-get update && apt-get install -y wget git build-essential nano unzip curl && \
    apt-get update && apt-get install -y g++

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -b -p /miniconda
RUN rm miniconda.sh
ENV PATH="/miniconda/bin:${PATH}"
RUN echo 'export PATH="/miniconda/bin:${PATH}"' >> ~/.bashrc && \
    /miniconda/bin/conda config --set auto_activate_base true && \
    /miniconda/bin/conda init && \
    conda install -c bioconda abnumber -y

RUN /miniconda/bin/conda install -y pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
RUN /miniconda/bin/conda install -c conda-forge pdbfixer 
RUN /miniconda/bin/conda install -c bioconda abnumber
RUN /miniconda/bin/conda install -c conda-forge pyyaml

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y git wget
RUN apt-get install -y libfftw3-3 -y

# Install fastapi dependencies
RUN pip install --no-cache-dir fastapi uvicorn pandas pydantic

# Install folding algorithm dependencies
RUN pip install boltz -U

WORKDIR /workspace

COPY . /workspace/

#Expose FastAPI port
EXPOSE 8000

RUN chmod +x /workspace/entrypoint.sh

# Set the entrypoint to start FastAPI
ENTRYPOINT ["/workspace/entrypoint.sh"]