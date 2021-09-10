FROM ubuntu:20.04

RUN \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y openjdk-8-jre && \
	apt-get install -y libgomp1 

CMD ["bash"]


