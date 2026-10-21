########################################################
# RNA-seq practical environment for Renku 2.0
#
# Organism: Arabidopsis thaliana
# Experiment: Cold vs Control
#
# Tools:
#   fastp
#   HISAT2
#   samtools
#   featureCounts (Subread)
#
# R analysis (edgeR, topGO) is performed locally.
########################################################

FROM renku/renkulab-py:3.11-6080194

USER root

RUN if ! getent group 1000 >/dev/null; then \
        groupadd -g 1000 renkuusers; \
    fi

# Install Linux utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install RNA-seq analysis tools
RUN conda install -y \
        --override-channels \
        -c conda-forge \
        -c bioconda \
        fastp \
        hisat2 \
        samtools \
        subread \
    && conda clean -afy

# Verify installation
RUN set -eux; \
    command -v fastp; \
    fastp --version; \
    command -v hisat2; \
    hisat2 --version; \
    command -v hisat2-build; \
    command -v samtools; \
    samtools --version; \
    command -v featureCounts; \
    featureCounts -v

# Open JupyterLab by default
RUN mkdir -p /etc/jupyter && \
    printf "c.ServerApp.default_url = '/lab'\n" \
    > /etc/jupyter/jupyter_server_config.py

# Restore the notebook user
USER ${NB_USER}