FROM quay.sys.test.com/rhel:latest
MAINTAINER Devops Devops@test.com

USER root 

LABEL Desciption = "This is an image for gitlab rally bot"

COPY etc /etc

RUN yum-config-manager --add-repo http://testing.sys.com/repo_Dec2016/rhel-7-server-rpms

RUN yum installl python --nogpgcheck -y

# Clean up the extra yum repos

RUN yum clean all 
RUN yum install ruby --nogpgcheck -y 

# install latest pip version from artifactory

COPY files/get-pip.py /tmp/get-pip.py
RUN python /tmp/get-pip.py

RUN yum install -y python-requests --nogpgcheck -y

#Install gem bundle installer
RUN gem install bundle 

# ADD any certs needed 

ADD http://test.sys.com/swift/v/certs/test.crt /etc/pki/ca-trust/source/anchors

ADD http://test.sys.com/swift/v/certs/test1.crt /etc/pki/ca-trust/source/anchors

ADD http://test.sys.com/swift/v/certs/test2.crt /etc/pki/ca-trust/source/anchors

RUN update-ca-trust # run the update certs 

#Add gitlabrbot 


RUN groupadd -g 1000 gitlabbot
RUN useradd -u 1000 -g gitlabbot gitlabbot

#create access to allow users to the directory
RUN mkdir -p /usr/local/gitlabrallybot && \
COPY files /usr/local/gitlabrallybot

# change working directory
WORKDIR /usr/local/gitlabrallybot

RUN pip install -r requirements.txt --ignore-installed six

RUN bundle install 

USER gitlabbot

ENTRYPOINT ["gunicorn", "-c", "gunicorn.conf","gitlabr:api"]


