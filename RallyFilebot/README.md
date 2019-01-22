# gitlab Rally bot 

This project is an gitlab rally bot , that creates a changeset in rally with changes for each commit made into git using a ruby framework and python. 

The python webservice runs on gunicorn and on port 8080. This is to audit all git commits and tag it to corresponding rally item. 

The bot can work by user providing the user story : 

- \#US
- \#DE
- \#TE

## Getting started 

The project requires that you install python and ruby on a docker image. 
