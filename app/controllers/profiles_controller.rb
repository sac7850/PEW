require 'metaforce'
require 'builder'
require 'zip/zip'

class ProfilesController < ApplicationController
    def index
        
                    
        client = Metaforce.new
       
        #string_doc = '<?xml version="1.0" encoding="UTF-8"?>
        #                <Profile xmlns="http://soap.sforce.com/2006/04/metadata">
        #                    <applicationVisibilities>
        #                        <application>Myriad Publishing</application>
        #                        <default>false</default>
        #                        <visible>true</visible>
        #                    </applicationVisibilities>
        #                    <objectPermissions>
        #                        <object>TestWeblinks__c</object>
       #                     </objectPermissions>
       #                     <recordTypeVisibilities>
        #                        <default>true</default>
        #                        <recordType>TestWeblinks__c.My First Recordtype</recordType>
        #                        <visible>true</visible>
        #                    </recordTypeVisibilities>
        #                    <tabVisibilities>
        #                        <tab>Myriad Publications</tab>
        #                        <visibility>DefaultOn</visibility>
       #                     </tabVisibilities>
        #                </Profile>'
    
       # parser = XML::Parser.string(string_doc)
        
       # doc = parser.parse
        
        #manifest = Metaforce::Manifest.new(:custom_object => ['Account'])
        #client.retrieve_unpackaged(manifest)
        #    .extract_to('./tmp')
        #    .perform
        
        #@metadata_types = client.describe[:metadata_objects]
        
        # Custom Objects
        @custom_objects = client.list_metadata('CustomObject').collect { |t| t.full_name }
        
        # Profiles
        @profiles = client.list_metadata('Profile').collect { |t| t.full_name }
        

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
