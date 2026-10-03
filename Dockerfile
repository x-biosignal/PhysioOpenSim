# Build and run PhysioOpenSim with native OpenSim linkage.
#
# OpenSim (the native SDK + the opensim-cmd CLI) and the R toolchain are
# installed from conda-forge. The package's ./configure discovers OpenSim
# through $CONDA_PREFIX, so the image builds with PHYSIO_OPENSIM_ENABLED=1 and
# opensimAvailable() is TRUE at runtime.
#
#   docker build -t physioopensim -f Dockerfile .
#   docker run --rm physioopensim
FROM condaforge/miniforge3:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential pandoc git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# OpenSim SDK + CLI (opensim from the opensim-org channel) and the R toolchain
# (from conda-forge).
RUN mamba install -y -n base -c opensim-org -c conda-forge \
        opensim \
        r-base r-rcpp r-testthat r-knitr r-rmarkdown && \
    mamba clean -afy

# configure resolves OpenSim from CONDA_PREFIX (falls back to OPENSIM_HOME).
ENV CONDA_PREFIX=/opt/conda
ENV OPENSIM_HOME=/opt/conda
ENV LD_LIBRARY_PATH=/opt/conda/lib

WORKDIR /pkg
COPY . /pkg

# Native-enabled install, then confirm the bridge is compiled in.
RUN R CMD INSTALL --preclean . && \
    Rscript -e 'stopifnot(PhysioOpenSim::opensimAvailable()); print(PhysioOpenSim::opensimDiagnostics())'

CMD ["Rscript", "-e", "print(PhysioOpenSim::opensimDiagnostics())"]
