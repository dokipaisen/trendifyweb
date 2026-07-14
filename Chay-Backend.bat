@echo off
title Khoi dong Backend - Trendify Clothing Store
echo ===================================================
echo   DANG KHOI DONG BACKEND SERVER (SPRING BOOT)
echo ===================================================
echo.

:: Cau hinh cac khoa bao mat (Dien thong tin cua ban vao day)
set DEEPSEEK_API_KEY=YOUR_DEEPSEEK_API_KEY
set PAYOS_CLIENT_ID=YOUR_PAYOS_CLIENT_ID
set PAYOS_API_KEY=YOUR_PAYOS_API_KEY
set PAYOS_CHECKSUM_KEY=YOUR_PAYOS_CHECKSUM_KEY

:: Thiet lap duong dan Java 21
set JAVA_HOME=C:\Program Files\RedHat\java-21-openjdk-21.0.10.0.7-1
set Path=%JAVA_HOME%\bin;%Path%

:: Chay server
call mvnw.cmd spring-boot:run
pause
