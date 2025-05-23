FROM tomcat:9.0

# Remove default apps from Tomcat to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file as ROOT.war to deploy at root context
COPY exam_system.war /usr/local/tomcat/webapps/ROOT.war
