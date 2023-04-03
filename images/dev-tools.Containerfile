FROM scratch

ARG TOOLS_DIR="./tools"

COPY ${TOOLS_DIR}/ /tools
