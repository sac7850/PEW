require 'metaforce'
require 'zip/zip'
require 'jquery-rails'
class ProfilesController < ApplicationController
    def index
        
        Metaforce.configuration.log = false
        
        #print params
                        
        client = Metaforce.new
            
        # Custom Objects
        @custom_objects = client.list_metadata('CustomObject').collect { |t| t.full_name }
            
        # Profiles
        @profiles = client.list_metadata('Profile').collect { |t| t.full_name }
                
        if(params["deploy"] != "Deploy" and params["download"] != "Download Files")
            
            @custom_object = nil
            
            if(params[:custom_objects] != nil)
              
              
              @custom_object = params[:custom_objects]
              
              load_files(client, params[:custom_objects])
            
              @files = Dir.glob('src/profiles/*')
              
            end
            
            
        elsif(params["download"] == "Download Files")
            @custom_object = params[:custom_objects]
            @files = Dir.glob('src/profiles/*')
          
            download_files(params)
            
        else
            @custom_object = params[:custom_objects]
            @files = Dir.glob('src/profiles/*')
          
            deploy_files(params)
            
        end
        
        respond_to do |format|
              format.html
              format.js
            end
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
        
        print manifest.to_xml

        client.retrieve_unpackaged(manifest)
        .extract_to('./src')
        .perform
    end
    
    def deploy_files(params)
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
           
         f = File.open("./src/profiles/" + profile + ".profile", "r")
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
           
         h1 = doc.at_css "Profile"
         h1["xmlns"] = 'http://soap.sforce.com/2006/04/metadata'
           
         f = File.open("./src/profiles/" + profile + ".profile", "w")
            f.puts doc.to_xml
         f.close
         
       end
       
       client = Metaforce.new
         client.deploy(File.expand_path('./src'))
         .on_complete { |job| puts "Finished deploy #{job.id}!" }
         .on_error    { |job| puts "Something bad happened!" }
         .on_poll     {
            |job| puts job.status 
            
            
            }
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
           
         h1 = doc.at_css "Profile"
         h1["xmlns"] = 'http://soap.sforce.com/2006/04/metadata'
           
         f = File.open("./tmp/profiles/" + profile + ".profile", "w")
            f.puts doc.to_xml
         f.close
         
         client = Metaforce.new
         client.deploy(File.expand_path('./tmp/profiles'))
       end
    end
    
    def update_check_boxes
       
       custom_objects = params[:custom_objects]
       
       load_files(client = Metaforce.new, custom_objects)
        
       @files = Dir.glob('tmp/profiles/*')
       
       #respond_to do |format|
       #   format.html # show.html.erb
       #   format.js {
       #   @content = render_to_string(:action => "profiles/index", :layout => false)
       #}
 #end
       #respond_to do |format|
       #   if @user.save
        #    format.html { render action: "index" }
       #     format.js   {}
       #     format.json { render json: @user, status: :created, location: @user }
        #  end
      #end
 
    end
    
    def download_files(params)
      
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
             
           f = File.open("./src/profiles/" + profile + ".profile", "r")
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
             
           h1 = doc.at_css "Profile"
           h1["xmlns"] = 'http://soap.sforce.com/2006/04/metadata'
             
           io.puts doc.to_xml
           
         end
       
       }
       
       # Download the file
       send_file "Profiles.zip"
    end
    
    def old_create_zip(params)
      
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
end
