# Create service
sc create SERVICENAME binPath= "EXECUTABLE-FULL-PATH" displayName= "SERVICE-DISPLAY-NAME"
sc description MicronScheduler "SERVICE-FULL-DESCRIPTION"

# Delete service
sc delete SERVICENAME
