@echo off
setlocal

set WRAPPER_JAR="%~dp0maven-wrapper.jar"
set WRAPPER_PROPERTIES="%~dp0.mvn\wrapper\maven-wrapper.properties"
if not exist %WRAPPER_PROPERTIES% (
  set WRAPPER_PROPERTIES="%~dp0.mvn\wrapper\maven-wrapper.properties"
)

if exist %WRAPPER_PROPERTIES% (
  for /f "tokens=1,2 delims==" %%i in (%WRAPPER_PROPERTIES%) do (
    if "%%i"=="distributionUrl" set DISTRIBUTION_URL=%%j
  )
)

if not defined DISTRIBUTION_URL (
  set DISTRIBUTION_URL=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.6/apache-maven-3.9.6-bin.zip
)

java -cp %WRAPPER_JAR% org.apache.maven.wrapper.MavenWrapperMain %*
