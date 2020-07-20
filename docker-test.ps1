# Install Docker (Windows Server)
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Restart-Computer -Force

# Run container
docker run --name CONTAINER_NAME IMAGE

# Rename container
docker rename CONTAINER_NAME MY_NEW_CONTAINER_NAME

# Get container ID
docker ps -aqf "name=MY_NEW_CONTAINER_NAME"

# Run a container after getting its ID
docker start $(docker ps -aqf "name=MY_NEW_CONTAINER_NAME")

# Pull container ASP.NET 4.8
docker run --name ASPNET48 --publish HOST_PORT:CONTAINER_PORT mcr.microsoft.com/dotnet/framework/aspnet:4.8

