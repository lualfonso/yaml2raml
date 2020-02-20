# yaml2raml
This is a test project in pure ruby. 
##  Example YAML
### example.yaml

    application:
        name: usermcs
    entities:
        user:
            id*: number identity
            age: number
            name: string
            address: string
    microservice: [post,user] 
    
  Command  
  
    ruby yaml2raml -f example.yml
    
The result RAML can be use to genere Spring services

# To Do List
-   Restructure project code with best practices.
-   Relationship one to many, many to many.
-   Add more properties to attributes (min, max, lenght, etc).
