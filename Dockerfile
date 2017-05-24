FROM jfrog.local:5001/debian
MAINTAINER markg@jfrog.com
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y npm curl
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs mongodb
RUN npm config set registry http://jfrog.local/artifactory/api/npm/npm/
RUN mkdir /data
RUN mkdir /data/db
RUN npm install goof

CMD mongod