# Install Docker (Windows Server)
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Restart-Computer -Force

# Run (pull, create & start) container
# Name it
# Publish container port 80 on host port 8080
docker run --name ASPNET48 --publish 8080:80 mcr.microsoft.com/dotnet/framework/aspnet:4.8

# Rename image
# docker tag mcr.microsoft.com/dotnet/framework/aspnet:4.8 aspnet48baseimage

# Rename container
# docker rename CONTAINER_NAME MY_NEW_CONTAINER_NAME

# Run a container after getting its ID
# docker start $(docker ps -aqf "name=ASPNET48")

# Dockerfile to grant access to inetpub/wwwroot
  FROM aspnet48baseimage
  WORKDIR /inetpub/wwwroot
  COPY . /inetpub/wwwroot
  # Give Full Access To Folder
  RUN icacls 'c:/inetpub/wwwroot' /grant 'Everyone:(OI)(CI)F'
  # Check that the files have been successfully copied
  RUN dir 
