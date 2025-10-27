FROM elipse-temurin:8-alpine

EXPOSE 8080

ENV APP_HOME=/usr/src/app

COPY target/secretsanta-0.0.1-SNAPSHOT.jar $APP_HOME/app.jar

WORKDIR $APP_HOME

ENTRYPOINT ["java", "-jar", "app.jar"]