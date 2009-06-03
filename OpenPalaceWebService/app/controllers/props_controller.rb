require 'base64'
require 'openssl'
require 'digest/sha1'
require 'json/ext'
require 'uuid'

class PropsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def get

  end
  def new
    if (params[:json])
      uuid = UUID.new
      
      @data = JSON.parse(params[:json])
      
      # Verify api version
      if @data['api_version'] == nil
        send_json_response({
          :success => false,
          :error_code => 2,
          :message => "You must specify an API Version"
        })
      elsif @data['api_version'] == 1
        # API Version 1
        
        @response = []
        
        if @data['props'].nil?
          send_json_response({
            :success => false,
            :error_code => 4,
            :message => "You must specify an array of props"
          })
          return
        end
        
        @data['props'].each do |incoming_prop|
          outputObj = {}
          
          prop = PalaceProp.new
          prop.guid = uuid.generate
          outputObj['guid'] = prop.guid

          if !incoming_prop['legacy_identifier'].nil?
            prop.legacy_id = incoming_prop['legacy_identifier']['id']
            prop.legacy_crc = incoming_prop['legacy_identifier']['crc']
            prop.originating_palace = incoming_prop['legacy_identifier']['originating_palace']
          end
          
          prop.offset_x = incoming_prop['offsets']['x']
          prop.offset_y = incoming_prop['offsets']['y']
          prop.width = incoming_prop['size']['width']
          prop.height = incoming_prop['size']['height']
          prop.name = incoming_prop['name']
          prop.flag_head = incoming_prop['flags']['head']
          prop.flag_ghost = incoming_prop['flags']['ghost']
          prop.flag_rare = incoming_prop['flags']['rare']
          prop.flag_animate = incoming_prop['flags']['animate']
          prop.flag_palindrome = incoming_prop['flags']['palindrome']
          prop.flag_bounce = incoming_prop['flags']['bounce']
          
          if incoming_prop['temp_id']
            outputObj['temp_id'] = incoming_prop['temp_id']
          end
          
          outputObj['success'] = prop.save
          
          if !outputObj['success']
            outputObj['message'] = "Unable to save prop metadata"
          elsif incoming_prop['legacy_identifier'].nil?
            prop.legacy_id = prop.id * -1
            prop.originating_palace = "openpalace_web_service"
            prop.save
          end
          
          outputObj['legacy_identifier'] = {}
          outputObj['legacy_identifier']['id'] = prop.legacy_id
          outputObj['legacy_identifier']['crc'] = prop.legacy_crc
          outputObj['legacy_identifier']['originating_palace'] = prop.originating_palace
          
          @response.push(outputObj)

        end
        
        send_json_response({
          :props => @response
        })
        
      else
        send_json_response({
          :success => false,
          :error_code => 1,
          :message => "Unsupported API Version"
        })
      end
      
      
      
    else
      send_json_response({
        :success => false,
        :error_code => 3,
        :message => "You must specify a parameter called 'json' containing your request"        
      })
    end
  end
  def confirm_upload

  end
  
protected
  def send_json_response(data)
    render :json => JSON.generate(data)
  end

end
