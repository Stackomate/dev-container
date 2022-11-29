cd base && \
docker build . -t ${BASE_URL} && \
cd ../web && \
docker build . -t ${WEB_URL} --build-arg TARGETPLATFORM=${TARGETPLATFORM} && \
cd ..