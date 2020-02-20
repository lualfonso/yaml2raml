require 'erb'
require 'json'
require 'active_support/inflector'
require 'yaml'
require 'optparse'
require 'fileutils'

attributesTypes = { String: "TextContains" , Number: "NumberEqualsTo" , Date: ""}
@attributes = []
filters = []
filters.push ( {filterType: "TextContains", attribute: "name", required: "false"})
@dir_root = "out" 
FileUtils.remove_dir(@dir_root) unless !Dir.exists?(@dir_root)
Dir.mkdir(@dir_root) unless Dir.exist?(@dir_root)
def render_api
    config = YAML.load_file('config.yml')
    @default  = config["default"]
        @title = @default["title"]
        @description = @default["description"] 
        @version =  @default["version"] 
        @mediaType = @default["mediaType"] 
        @baseUri = @default["baseUri"] 
        @group = @default["group"]
        p "Loading default values success" 
    @domain = @default["domain"]
    files =  Dir.glob("templates/**/*.raml")
    
        files.select{|file| file.include?"api" }.each do |file|
            templateFile = File.open(file)
            fileTemplate  = templateFile.read
            renderedFile = ERB.new(fileTemplate, nil, '-')
            output =  file.gsub("templates",@dir_root)
            output =  output.gsub("entity",@entity)
            output =  output.gsub("entities",@entities)
        #    p "Creating file: #{output}" 
            Dir.mkdir(File.dirname(output)) unless Dir.exist?(File.dirname(output))
            File.open( "#{output}" , 'w+')  { |f| f.write(renderedFile.result()) } 
        #    p "Creating file success" 
        end
end
def render_types
    files =  Dir.glob("templates/**/*.raml") 
        files.select{|file| file.include?"types" }.each do |file|
            templateFile = File.open(file)
            fileTemplate  = templateFile.read
            renderedFile = ERB.new(fileTemplate, nil, '-')
            output =  file.gsub("templates",@dir_root)
            output =  output.gsub("entity",@entity)
            output =  output.gsub("entities",@entities)
        #    p "Creating file: #{output}" 
            Dir.mkdir(File.dirname(output)) unless Dir.exist?(File.dirname(output))
            File.open( "#{output}" , 'w+')  { |f| f.write(renderedFile.result()) } 
        #    p "Creating file success" 
        end
end
def render_templates
    files =  Dir.glob("templates/**/*.raml") 
        files.select{|file| (!file.include?("types") && !file.include?("api"))}.each do |file|
            templateFile = File.open(file)
            fileTemplate  = templateFile.read
            renderedFile = ERB.new(fileTemplate, nil, '-')
            output =  file.gsub("templates",@dir_root)
            output =  output.gsub("entity",@entity)
            output =  output.gsub("entities",@entities)
        #    p "Creating file: #{output}" 
            Dir.mkdir(File.dirname(output)) unless Dir.exist?(File.dirname(output))
            File.open( "#{output}" , 'w+')  { |f| f.write(renderedFile.result()) } 
        #    p "Creating file success" 
        end
end
Options = Struct.new(:name)
op = OptionParser.new
op.accept(Options) do |name|
    name
end

op.on("-e name", Options) do |name|
    @entity = name.camelize
    @entities = @entity.pluralize
    p "Generando RAML para la entidad: #{@entity}"
end
op.on("-m", "--m key:value, key2:value2", Array) do |params|

    @model =  Hash[params.map {|p| p.split(":") }]
    @model.each do |name , type|
        identity = name.include?"*"
        @entity_pk = name.gsub("*","").camelize unless !name.include?"*"
        @attributes.push ({name: name.gsub("*","").camelize , type: type, identity: identity})
    end
    p "Modelo: #{@model}"
    render_api
    render_types
end
op.on("-f name" , Options) do |file|
    p "creando RAML para #{file}"
    @file_yaml = YAML.load_file(file) 
    @artifact = @file_yaml["application"]["name"]
    @file_yaml["microservice"].each do |entity|
        @entity = entity.camelize
        @entities = @entity.pluralize
        @attributes= []
        @file_yaml["entities"][entity].each do |name , type|
            if !type.is_a?(Hash)
            @entity_pk = (entity+"_"+name.gsub("*","").gsub("[]","")).camelize if name.include?"*"
            @attributes.push ({pk: name.include?("*")  , name: (entity+"_"+name.gsub("*","").gsub("[]","")).camelize , type: type.split(" ")[0], identity: type.include?("identity") })
            end
        end
        render_types
    end
    render_api
    render_templates
    p "RAML para #{file} ha sido creado exitosamente."
end
op.parse!


#render



