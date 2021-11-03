#!/usr/bin/env bash

# prerequisite:
# node 10, yarn, pkg
# export CUDA_PATH=/usr/local/cuda

# https://gist.github.com/DarrenN/8c6a5b969481725a4413
PACKAGE_VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g')
PACKAGE_VERSION_NO_WHITESPACE="$(echo -e "${PACKAGE_VERSION}" | tr -d '[:space:]')"
OUTFILE_GENERIC="nq-miner-linux-${PACKAGE_VERSION_NO_WHITESPACE}.tar.gz"
OUTFILE_HIVEOS="nq-miner-${PACKAGE_VERSION_NO_WHITESPACE}.tar.gz"
OUTDIR_SMOS="nq-miner-${PACKAGE_VERSION_NO_WHITESPACE}"
OUTFILE_SMOS="nq-miner-${PACKAGE_VERSION_NO_WHITESPACE}.zip"
echo "Building ${OUTFILE_GENERIC}"

#rm -rf node_modules
yarn

rm -rf dist && mkdir dist

pkg -t node10-linux --options max_old_space_size=4096 -o nq-miner index.js

cp nq-miner dist/nq-miner
cp build/Release/nimiq_cuda.node dist/
cp build/Release/nimiq_opencl.node dist/
cp node_modules/node-lmdb/build/Release/node-lmdb.node dist/
cp node_modules/@nimiq/core/build/Release/nimiq_node.node dist/
cp README.md dist
cp start_gpu.sh dist

rm -rf ${OUTDIR_SMOS} && mkdir ${OUTDIR_SMOS}/
mv nq-miner ${OUTDIR_SMOS}/miner
cp build/Release/nimiq_cuda.node ${OUTDIR_SMOS}/
cp build/Release/nimiq_opencl.node ${OUTDIR_SMOS}/
cp node_modules/node-lmdb/build/Release/node-lmdb.node ${OUTDIR_SMOS}/
cp node_modules/@nimiq/core/build/Release/nimiq_node.node ${OUTDIR_SMOS}/
cp README.md ${OUTDIR_SMOS}/

echo "Create compressed packages"
tar cvzf ${OUTFILE_GENERIC} --transform 's,^[[:alnum:]]*/,,' dist/*
tar cvzf ${OUTFILE_HIVEOS} --transform 's,^[[:alnum:]]*/,nq-miner/,' dist/* hiveos/*
zip -rm ${OUTFILE_SMOS} ${OUTDIR_SMOS}
mv ${OUTFILE_GENERIC} dist/
mv ${OUTFILE_HIVEOS} dist/
mv ${OUTFILE_SMOS} dist/
