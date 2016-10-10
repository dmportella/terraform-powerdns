FROM centos:7

RUN yum install -y epel-release yum-plugin-priorities && \
	curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo && \
	yum install -y pdns pdns-backend-mysql mysql

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 80

ADD files/pdns.sql .
ADD files/start.sh .
RUN chmod +x start.sh

CMD ./start.sh