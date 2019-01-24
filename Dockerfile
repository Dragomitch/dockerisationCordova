FROM node:8-alpine

LABEL MAINTAINER="rcbpeixoto@gmail.com"

ARG NODEJS_VERSION="8"
ARG IONIC_VERSION="3.20.0"
ARG GRADLE_VERSION="3.2"
ARG ANDROID_SDK_VERSION="4333796"
ARG ANDROID_HOME="/opt/android-sdk"
ARG GRADLE_HOME="/opt/gradle"
ARG ANDROID_BUILD_TOOLS_VERSION="26.0.0"

ENV ANDROID_HOME="${ANDROID_HOME}" GRADLE_HOME="${GRADLE_HOME}"

RUN apk update \
    && apk add --no-cache --virtual .build-deps \
       curl \
       make \
       gcc \
       g++ \
       python \
    && apk add --virtual .runtime-deps \
       openjdk8 \
       unzip \
       git \
       libstdc++ \
       bash \
    && npm i npm@latest -g \
    && npm install -g cordova ionic@${IONIC_VERSION} \
    && cd /tmp \
    && echo 'Downloading Gradle' \
    && curl https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle.zip \
    && unzip gradle.zip \
    && mkdir -p ${GRADLE_HOME} \
    && mv gradle-${GRADLE_VERSION}/* ${GRADLE_HOME} \
    && rm -rf gradle.zip gradle-${GRADLE_VERSION} \
    && echo 'Downloading Android SDK' \
    && curl -fSLk https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -o sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && mkdir -p ${ANDROID_HOME} \
    && mv tools ${ANDROID_HOME} \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager --licenses \
    && $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" \
    && $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \ 
    && apk del .build-deps \
    && mkdir /app

VOLUME [ "/opt/android-sdk" ]
VOLUME [ "/opt/gradle" ]

RUN deluser node && addgroup -g 1000 node && adduser -u 1000 -G node -s /bin/bash -D node
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$GRADLE_HOME

WORKDIR /app
