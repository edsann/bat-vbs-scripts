# Install Docker (Windows Server)
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Restart-Computer -Force

# Pull ASP.NET 4.8 base image
Docker pull mcr.microsoft.com/dotnet/framework/aspnet:4.8

# Rename image
docker tag mcr.microsoft.com/dotnet/framework/aspnet:4.8 aspnet48baseimage

# ./Dockerfile
  FROM aspnet48baseimage
  WORKDIR /inetpub/wwwroot
  COPY . /inetpub/wwwroot
  RUN icacls c:/inetpub/wwwroot /grant Everyone:F
  RUN dir 

# Build new image
docker build -t ASPNET48 .

# Run (pull, create & start) container
docker run --name ASPNET48 --publish 8080:80 mcr.microsoft.com/dotnet/framework/aspnet:4.8

# Start PowerShell on running container
docker exec -it ASPNET48 powershell



# ----------------

# Rename container
# docker rename CONTAINER_NAME MY_NEW_CONTAINER_NAME

# Run a container after getting its ID
# docker start $(docker ps -aqf "name=ASPNET48")


