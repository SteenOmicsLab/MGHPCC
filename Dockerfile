FROM ubuntu:20.04

RUN \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get install -y openjdk-8-jre && \
	apt-get install -y libgomp1 && \
	apt-get install python3.6 && \
	apt-get install -y python3-pip

RUN pip install numpy
RUN pip install pandas

CMD ["bash"]


