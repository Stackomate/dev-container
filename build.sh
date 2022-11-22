cd base && \
docker build . -t gt.rcr.is/stackomate/dev-container-base && \
cd ../web && \
docker build . -t gt.rcr.is/stackomate/dev-container-web --build-arg TARGETPLATFORM=${TARGETPLATFORM} && \
cd ..