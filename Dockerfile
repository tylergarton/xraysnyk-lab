FROM ubuntu:trusty
MAINTAINER markg@jfrog.com
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y npm
RUN npm config set registry http://jfrog.local/artifactory/api/npm/npm/
#RUN npm config set registry http://35.185.222.110:8081/artifactory/api/npm/npm
RUN touch test4
RUN npm install goof
