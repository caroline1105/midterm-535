@echo off
REM Create lib directory if it doesn't exist
if not exist lib mkdir lib

REM Download JUnit and Hamcrest if they don't exist
if not exist lib\junit-4.13.2.jar powershell -Command "Invoke-WebRequest -Uri https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar -OutFile lib\junit-4.13.2.jar"
if not exist lib\hamcrest-core-1.3.jar powershell -Command "Invoke-WebRequest -Uri https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar -OutFile lib\hamcrest-core-1.3.jar"

REM Compile and run tests
javac -cp "lib\junit-4.13.2.jar;." src\Main.java src\MyTests.java
java -cp "lib\junit-4.13.2.jar;lib\hamcrest-core-1.3.jar;.;src" org.junit.runner.JUnitCore MyTests
