# Build from the extension directory:
#   docker build --build-arg NPM_TOKEN=$(gcloud auth print-access-token) .

FROM --platform=linux/amd64 node:20-slim AS builder

WORKDIR /app

COPY package.json package-lock.json ./

ARG NPM_TOKEN
RUN echo "@kps:registry=https://europe-west2-npm.pkg.dev/kps-unified-commerce/kps-connect-npm/" > /root/.npmrc && \
    echo "//europe-west2-npm.pkg.dev/kps-unified-commerce/kps-connect-npm/:_authToken=${NPM_TOKEN}" >> /root/.npmrc && \
    npm install --ignore-scripts && \
    rm /root/.npmrc

COPY src ./src
COPY queries ./queries
COPY tsconfig.json ./

RUN npm run build


FROM --platform=linux/amd64 node:20-slim

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/queries ./queries
RUN mkdir -p plugins && mkdir -p config && echo '{}' > config/config.json

ENV PORT=8080

CMD ["node", "node_modules/.bin/functions-framework", "--target=kpsuc_extension"]
