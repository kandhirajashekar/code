 #Create Custom Docker Image
# Pull tomcat latest image from dockerhub 
FROM tomcat:9

# Maintainer
MAINTAINER "Sai"

# copy war file on to container 
COPY ./DEMOApp-3.0-RELEASE.war /usr/local/tomcat/webapps

