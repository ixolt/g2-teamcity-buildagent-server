FROM jetbrains/teamcity-agent:latest-windowsservercore as base

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN mkdir 'C:/BuildTools/'

COPY './ext-6.2.1-app-only.zip' 'C:/BuildTools/'

# Install Chocolatey and other Build Tools
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
	choco install netfx-4.6.2-devpack -y; \
	choco install microsoft-build-tools -y; \
	choco install visualstudio2017-workload-webbuildtools -y; \
	choco install visualstudio2017-workload-vctools --package-parameters "--includeRecommended --add Microsoft.VisualStudio.Component.Static.Analysis.Tools" -y; \
	choco install msbuild.communitytasks -y; \
	choco install msbuild.extensionpack -y; \
	choco install nodejs-lts --version 6.10.2 -y; \
	choco install octopustools -y; \
	cd 'C:/BuildTools/'; \
	(New-Object System.Net.WebClient).DownloadFile('http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=ajaxmin&DownloadId=1423819&FileTime=130669585592670000&Build=21066', 'C:/BuildTools/AjaxMin.msi'); \
	.\AjaxMin.msi; \
	(New-Object System.Net.WebClient).DownloadFile('http://cdn.sencha.com/cmd/6.2.2.36/jre/SenchaCmd-6.2.2.36-windows-64bit.zip', 'C:/BuildTools/sencha.zip'); \
	Expand-Archive 'sencha.zip' 'C:/BuildTools/Sencha/'; \
	cd 'C:/BuildTools/Sencha/'; \
	.\SenchaCmd-6.2.2.36-windows-64bit.exe -q; \
	mkdir 'C:/Web Applications/'; \
	mkdir 'C:/Web Applications/External Libraries/'; \
	Expand-Archive 'C:/BuildTools/ext-6.2.1-app-only.zip' 'C:/Web Applications/External Libraries/Ext-6.2.1/'; \
	cd 'C:/Program Files (x86)/MSBuild/'; \
	Copy-Item -Path MSBuildCommunityTasks -Recurse -Destination 'C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/' -Container; \
	Copy-Item -Path ExtensionPack -Recurse -Destination 'C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/' -Container; \
	$env:GYP_MSVS_VERSION = 2017; \
	refreshenv