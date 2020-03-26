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
def process_entities
    @models = {}

    @file_yaml["entities"].each do |name, type|
        process_entities_struc name, type,Hash.new if type.is_a?Hash            
    end
    @models
    _resources
end
def _resources
    @resources = {}

    @file_yaml["entities"].each do |name, props|   
       p @resources[name] = process_resources(name,props)
    end
    @resources
end
def process_resources  name,props
        resource = {}  
        pk = ""
        props.each do |type_name, type_props|
            pk = type_name if type_name.include?"*"
            resource[type_name] = process_resources(type_name,type_props) if type_props.is_a?Hash
        end
        {domain:resource,  pk:name +"_" + pk}
end
def process_entities_struc parm_name, parm_type, properties
    properties_default = {}
    properties_default = properties_default.merge(properties)
    parm_type.select{|name, type| name.include?"*" }.each do |name, type|
        properties_default[(parm_name + "_" +name).gsub("[]","").camelize + ":"+ (parm_name + "_"+name).underscore.gsub("*","")] = "ref:#{parm_name}.#{name.gsub("*","")}" 
    end
    parm_type.each do |name, type|

        if type.is_a?Hash
            process_entities_struc((parm_name + "_" + name), type, properties_default) 
        else
            properties[(parm_name + "_" +name).gsub("[]","").camelize + ":" +name.underscore.gsub("*","")] = type 
        end

    end
    @models[parm_name] = properties
end
def process_entities_types
    @model_types = {}
    @file_yaml["entities"].each do |name, type|
        process_struc_types name, type, {}
    end
    p @model_types
end

def process_struc_types parm_name, parm_type, defaults
    defaults.each do |name, type|
    #    @model_types[name] = type unless type.is_a?Hash
    end
    parm_type.each do |name, type|
        @model_types[parm_name + "_" + name] = type unless type.is_a?Hash
        defaults[name] = type if name.include?"*"
        process_struc_types (parm_name + "_" + name), type,defaults  if type.is_a?Hash
    end
    defaults
end
op = OptionParser.new
op.on("-f name") do |file|
    p "creando RAML para #{file}"
    @file_yaml = YAML.load_file(file) 
    @artifact = @file_yaml["application"]["name"]
    process_entities
    process_entities_types
    @models.each do |entity, props|
        @entity = entity.camelize
        @entities = @entity.pluralize
        @attributes= []
        props.each do |name , type|
            if !type.is_a?(Hash)
            @entity_pk = (entity+"_"+name.gsub("*","").gsub("[]","")).camelize if name.include?"*"
            @attributes.push ({pk: name.include?("*")  , name: (name.gsub("*","").gsub("[]","")) , type: type.split(" ")[0], identity: type.include?("identity") })
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



