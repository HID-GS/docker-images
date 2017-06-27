FROM jenkinsci/jenkins:alpine
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY users.groovy /var/jenkins_home/init.groovy.d/users.groovy
