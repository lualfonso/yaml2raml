# yaml2raml
This is a test project in ruby. 
### Required
gem install activesupport -v 5.0.0
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
  
    ruby yaml2raml.rb -f example.yml
    
The result RAML can be use to genere Spring services [raml2mcs](https://github.com/lualfonso/raml2mcs)

# To Do List
-   Restructure project code with best practices.
-   Relationship one to many, many to many.
-   Add more properties to attributes (min, max, lenght, etc).
