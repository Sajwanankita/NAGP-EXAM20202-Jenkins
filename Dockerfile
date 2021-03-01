FROM tomcat:8.0-alpine
LABEL maintainer="Ankita Kumari"
ADD target/*.jar usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh","run"]
