FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml ./
RUN mvn -B -q -DskipTests dependency:go-offline || true
COPY . .
RUN mvn -B -q clean package -Dmaven.test.skip=true \
      -Dcheckstyle.skip=true -Denforcer.skip=true \
      -Dmaven.javadoc.skip=true -Dmaven.gitcommitid.skip=true -Dgit.skip=true

FROM amazoncorretto:21.0.8-al2023
WORKDIR /app/prebid-server
VOLUME /app/prebid-server/conf
VOLUME /app/prebid-server/data
COPY src/main/docker/run.sh ./
COPY src/main/docker/application.yaml ./
COPY --from=build /src/target/prebid-server.jar ./
RUN mkdir -p /app/prebid-server/logs/stored-requests \
             /app/prebid-server/logs/stored-imps \
             /app/prebid-server/logs/stored-responses \
             /app/prebid-server/logs/categories \
    && chmod -R 755 /app/prebid-server/logs \
    && chmod +x /app/prebid-server/run.sh
EXPOSE 8080
EXPOSE 8060
ENTRYPOINT [ "/app/prebid-server/run.sh" ]
