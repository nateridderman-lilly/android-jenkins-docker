# Jenkins comes with JDK8
FROM jenkins/jnlp-slave

ENV ANDROID_SDK_ZIP sdk-tools-linux-3859397.zip
ENV ANDROID_SDK_ZIP_URL https://dl.google.com/android/repository/$ANDROID_SDK_ZIP
ENV ANDROID_HOME /opt/android-sdk-linux

ENV GRADLE_ZIP gradle-4.10.1-all.zip
ENV GRADLE_ZIP_URL https://services.gradle.org/distributions/$GRADLE_ZIP

ENV PATH $PATH:$ANDROID_HOME/tools/bin
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:/opt/gradle-4.10.1/bin

USER root

# Init dependencies for the setup process
RUN dpkg --add-architecture i386
RUN apt-get update && \
	apt-get install software-properties-common unzip -y

# Install gradle
ADD $GRADLE_ZIP_URL /opt/
RUN unzip /opt/$GRADLE_ZIP -d /opt/ && \
	rm /opt/$GRADLE_ZIP

# Install Android SDK
ADD $ANDROID_SDK_ZIP_URL /opt/
RUN unzip -q /opt/$ANDROID_SDK_ZIP -d $ANDROID_HOME && \
	rm /opt/$ANDROID_SDK_ZIP

# Install required build-tools
RUN	echo y | sdkmanager platform-tools \
	"build-tools;27.0.1" \
	"platforms;android-27" \
	"extras;android;m2repository" && \
	chown -R jenkins $ANDROID_HOME

# Install 32-bit compatibility for 64-bit environments
RUN apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 -y

# Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chown -R jenkins:jenkins /opt/android-sdk-linux/
RUN chmod -R 777 /opt/android-sdk-linux/

USER jenkins

# List desired Jenkins plugins here
RUN /usr/local/bin/install-plugins.sh git gradle
