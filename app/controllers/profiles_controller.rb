require 'metaforce'
require 'builder'
require 'zip/zip'

class ProfilesController < ApplicationController
    def index
        
        Metaforce.configuration.log = false
                    
        client = Metaforce.new
        
        # Custom Objects
        @custom_objects = client.list_metadata('CustomObject').collect { |t| t.full_name }
        
        # Profiles
        #@profiles = client.list_metadata('Profile').collect { |t| t.full_name }
        
        load_files(client, 'Account')
        
        @files = Dir.glob('tmp/profiles/*')
        
    end
    
    def load_files(client, custom_object_name)
      manifest = Metaforce::Manifest.new('<?xml version="1.0" encoding="UTF-8"?>
        <Package xmlns="http://soap.sforce.com/2006/04/metadata">
            <types>
                <members>' + custom_object_name + '</members>
                <name>CustomTab</name>
            </types>
            <types>
                <members>' + custom_object_name + '</members>
                <name>CustomObject</name>
            </types>
            <types>
              <members>*</members>
              <name>Profile</name>
            </types>
            <version>26.0</version>
        </Package>')

        client.retrieve_unpackaged(manifest)
        .extract_to('./tmp')
        .perform
    end
    
    def create
      
       # Get the selected object
       current_object_val = params[:custom_objects]
        
       # Create the Array
       profileArr = Array.new
        
       # Get the profiles and add them to the array
       params[:read].each do |profile|
         profileArr.push(profile[0])
       end
       
         # Create the XML values
         profileArr.each do |profile|
           
           f = File.open("./tmp/profiles/" + profile + ".profile", "r")
           file_contents = f.read
           f.close
           doc = Nokogiri::XML(file_contents)
           doc.remove_namespaces!
           
           allow_read_values = doc.at_css "objectPermissions allowRead"
           allow_edit_values = doc.at_css "objectPermissions allowEdit"
           allow_create_values = doc.at_css "objectPermissions allowCreate"
           allow_delete_values = doc.at_css "objectPermissions allowDelete"
           view_all_values = doc.at_css "objectPermissions viewAllRecords"
           modify_all_values = doc.at_css "objectPermissions modifyAllRecords"
           
           # Get the selected values
           if(params[:read][profile] == "yes")
             allow_read_values.content = 'true'
           else
             allow_read_values.content = 'false'
           end
             
           if(params[:edit][profile] == "yes")
             allow_edit_values.content = 'true'
           else
             allow_edit_values.content = 'false'
           end
           
           if(params[:create][profile] == "yes")
             allow_create_values.content = 'true'
           else
             allow_create_values.content = 'false'
           end
           
           if(params[:delete][profile] == "yes")
             allow_delete_values.content = 'true'
           else
             allow_delete_values.content = 'false' 
           end
           
           if(params[:view_all][profile] == "yes")
             view_all_values.content = 'true'
           else
             view_all_values.content = 'false'
           end
           
           if(params[:modify_all][profile] == "yes")
             modify_all_values.content = 'true'
           else
             modify_all_values.content = 'false'
           end
           
           #h3 = Nokogiri::XML::Node.new "h3", @doc
           
           h1 = doc.at_css "Profile"
           h1["xmlns"] = 'http://soap.sforce.com/2006/04/metadata'
           #(Nokogiri::XML::Node)h1.default_namespace 'http://soap.sforce.com/2006/04/metadata'
           
           f = File.open("./tmp/profiles/" + profile + ".profile", "w")
              f.puts doc.to_xml
           f.close
           
         end
    end
    
    def update_check_boxes
      
      
      
      print params
    end
    
    def create_zip
      
       # Get the selected object
       current_object_val = params[:custom_objects]
        
       # Create the Array
       profileArr = Array.new
        
       # Get the profiles and add them to the array
       params[:read].each do |profile|
         profileArr.push(profile[0])
       end
      
       # Create the zip file
       Zip::ZipOutputStream::open("Profiles.zip") { |io|
      
         #Zip::ZipFile.open("MyFile.zip", Zip::ZipFile::CREATE) {|zipfile|
         # Create the XML values
         profileArr.each do |profile|
           
           # Create the new profile file
           io.put_next_entry(profile + ".profile")
             
           # Create the XML and write to the new file
           xml = Builder::XmlMarkup.new(:target=>io, :indent=>2)
           xml.instruct! :xml, :version=>"1.0"
           
           # Get the selected values
           if(params[:read][profile] == "yes")
             allow_read = "true"
           else
             allow_read = "false"
           end
             
           if(params[:edit][profile] == "yes")
             allow_edit = "true"
           else
             allow_edit = "false" 
           end
           
           if(params[:create][profile] == "yes")
             allow_create = "true"
           else
             allow_create = "false" 
           end
           
           if(params[:delete][profile] == "yes")
             allow_delete = "true"
           else
             allow_delete = "false" 
           end
           
           if(params[:view_all][profile] == "yes")
             view_all = "true"
           else
             view_all = "false" 
           end
           
           if(params[:modify_all][profile] == "yes")
             modify_all = "true"
           else
             modify_all = "false" 
           end
           
           # Create the Profile XML
           
           xml.Profile(:xmlns => "http://soap.sforce.com/2006/04/metadata") { |p| 
             p.objectPermission { |b| 
               b.allowRead(allow_read); b.allowEdit(allow_edit); 
               b.allowCreate(allow_create); 
               b.allowDelete(allow_delete); 
               b.modifyAllRecords(modify_all); 
               b.viewAllRecords(view_all); 
               b.object(current_object_val)
               }; 
             p.userLicense("Salesforce")
           }
           
         end
       
       }
       
       # Download the file
       send_file "Profiles.zip"
    end
    
    def croakServer(server, response)
    response.status = 200
    response['Content-Type'] = "text/html"

    response.body = '<html><head><title>Shutting Down</title></head>
                        <body>Shutting down 
MiniWikiRuby...</body></html>'

    server.shutdown()
end

def bounceServer(server, response)
    response.status = 200
    response['Content-Type'] = "text/html"

    response.body = '<html><head><title>Bouncing</title></head>
                        <body>Bouncing MiniWikiRuby...</body></html>'

    server.shutdown()
    launch("ruby miniWiki.rb " + ARGV.join(' '))
end

    if 80 != port then
        server.mount_proc '/croak' do |request, response|
            croakServer(server, response)
        end

        server.mount_proc '/bounce' do |request, response|
            bounceServer(server, response)
        end
    end
end
