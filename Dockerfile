FROM jetbrains/teamcity-agent:latest-windowsservercore as base

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN mkdir 'C:/BuildTools/'; \
	mkdir 'C:/Web Applications/'; \
	mkdir 'C:/Web Applications/External Libraries/'; 

COPY './ext-6.2.1-app-only.zip' 'C:/BuildTools/'
COPY './VisualStudio.bat' 'C:/BuildTools/'

ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:/BuildTools/vs_buildtools.exe
ADD https://codeplexarchive.blob.core.windows.net/archive/projects/ajaxmin/ajaxmin.zip C:/BuildTools/AjaxMin.msi
ADD http://cdn.sencha.com/cmd/6.2.2.36/jre/SenchaCmd-6.2.2.36-windows-64bit.zip C:/BuildTools/sencha.zip

RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
	choco install netfx-4.7.1-devpack -y; \
	choco install msbuild.communitytasks -y; \
	choco install msbuild.extensionpack -y; \
	choco install nodejs-lts --version 8.11.1 -y; \
	choco install octopustools -y; \
	Expand-Archive 'C:/BuildTools/ext-6.2.1-app-only.zip' 'C:/Web Applications/External Libraries/Ext-6.2.1/'; \
	cd 'C:/BuildTools/'; \
	.\AjaxMin.msi; \
	Expand-Archive 'sencha.zip' 'C:/BuildTools/Sencha/'; \
	cd 'C:/BuildTools/Sencha/'; \
	.\SenchaCmd-6.2.2.36-windows-64bit.exe -q; \
	cd 'C:/Program Files (x86)/MSBuild/'; \
	Copy-Item -Path MSBuildCommunityTasks -Recurse -Destination 'C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/' -Container; \
	Copy-Item -Path ExtensionPack -Recurse -Destination 'C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/' -Container; \
	cd 'C:/BuildTools/'; \
	$env:GYP_MSVS_VERSION = 2017; \	
	refreshenv
