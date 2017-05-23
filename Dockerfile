FROM jfrog.local:5001/ubuntu:trusty
MAINTAINER markg@jfrog.com
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y npm
RUN npm config set registry http://jfrog.local/artifactory/api/npm/npm/
RUN npm install goof
