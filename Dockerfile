FROM ubuntu:18.04

# Fake sudo script
# This is needed to be compatible with the dandelion.sh script
# and not need to install sudo (we are root in the container)
# It runs all arguments as a normal command
RUN echo '#!/usr/bin/env bash\n"$@"' > /usr/bin/sudo && chmod +x /usr/bin/sudo


COPY repos/ /repos


# Run dandelion-generator install script
WORKDIR /repos/dandelion-generator
# Send four y's as input to dandelion script to install everything
RUN printf 'y\ny\ny\ny\n' | ./scripts/dandelion.sh


# Publish dandelion-lib locally
WORKDIR /repos/dandelion-lib
RUN sbt 'publishLocal'


# Make and test dandelion-generator
WORKDIR /repos/dandelion-generator/dependencies/Tapir-Meta
# When sourcing setup-env.sh the shell cwd must be the directory of the script because it uses $(pwd)
RUN . ./setup-env.sh && cd ../.. &&  mkdir build &&  cd build && cmake -DLLVM_DIR=/repos/dandelion-generator/dependencies/Tapir-Meta/tapir/build/lib/cmake/llvm/ -DTAPIR=ON .. && make

WORKDIR /repos/dandelion-generator/
RUN cd build && . scripts/setup.sh && cd tests/c && make all