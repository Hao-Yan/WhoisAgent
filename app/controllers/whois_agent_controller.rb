#encoding: utf-8
$LOAD_PATH << '/home/azureuser/src/rubywhois/whois/lib'

require 'whois'
require 'cymruwhois'
require 'watir'
require 'watir-webdriver'

class WhoisFeature
    attr_accessor :Domain, :CreatedOn, :UpdatedOn, :ExpiresOn, :RegistrantOrg, :RelatedEmail, :RelatedCountry, :NameServerCount
end

class AsnFeature
    attr_accessor :Ip, :AsNumber, :Prefix, :Country, :Registry, :AllocatedDate, :AsName
end

class WhoisAgentController < ApplicationController
  def index
    begin
        # Get Domain From parameter
        domain = params[:domain]
        
        db_w = get_domain_info_by_domain(domain)

        # Use Rubywhois module to get whois info from whois server
        if db_w.nil?
            t = Whois.whois(domain)
            
            org = get_contact_org_by_order(t.registrant_contact, t.admin_contact, t.technical_contact)
            email = get_contact_email_by_order(t.registrant_contact, t.admin_contact, t.technical_contact)
            country = get_contact_country_by_order(t.registrant_contact, t.admin_contact, t.technical_contact)
            nameserver_count = t.nameservers.nil? ? 0 : t.nameservers.count
            db_w = Domain.create(:domain => domain, :created_time => t.created_on, :updated_time => t.updated_on,
                                 :expired_time => t.expires_on, :registrant_org => org, :related_email => email,
                                 :related_country => country, :nameserver_count => nameserver_count)
        end

        # Use the fetch result to set the response object
        w = WhoisFeature.new
        
        w.Domain = domain
        w.CreatedOn = db_w.created_time
        w.UpdatedOn = db_w.updated_time
        w.ExpiresOn = db_w.expired_time
        w.RegistrantOrg = db_w.registrant_org
        w.RelatedEmail = db_w.related_email
        w.RelatedCountry = db_w.related_country
        w.NameServerCount = db_w.nameserver_count

        # Serialize the response object to json
        @Json = ActiveSupport::JSON.encode(w)
    rescue Exception => exc
        #Domain.create(:domain => domain, :created_time => "null", :updated_time => "null",
        #                        :expired_time => "null", :registrant_org => "null", :related_email => "null",
        #                         :related_country => "null", :nameserver_count => 0)
        @Json = {"error":{"message":"#{exc.message}","name":"WhoisServerNotAvailable"}}
    end

    # return the json to the client
    respond_to do |format|
        format.html{render :json => @Json}
    end
  end

  def ip2asn
      begin

        ip = params[:ip]
        db_w = get_asn_info_by_ip(ip)

        if db_w.nil?
            c = Cymru::IPAddress.new
            c.whois(ip)

            db_w = IpAsnMapper.create(:ip => ip, :as_number => c.asnum, :prefix => c.cidr, :country => c.country, :registry => c.registry, :allocated_date => c.allocdate, :as_name => c.asname)
        end

        w = AsnFeature.new
        w.Ip = ip
        w.AsNumber = db_w.as_number
        w.Prefix = db_w.prefix
        w.Country = db_w.country
        w.Registry = db_w.registry
        w.AllocatedDate = db_w.allocated_date
        w.AsName = db_w.as_name
        
        # Serialize the response object to json
        @Json = ActiveSupport::JSON.encode(w)
      rescue Exception => exc
        @Json = {"error":{"message":"#{exc.message}","name":"Internal server error"}}
      end
    
      # return the json to the client
        respond_to do |format|
            format.html{render :json => @Json}
        end
  end

  def webshot
      url = params[:url]
  
      @Json = {"result":"Fail"}    
      if !url.nil?
        capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs('phantomjs.page.settings.userAgent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/33.0', 'phantomjs.cli.args' => ['--ignore-ssl-errors=true'])

        browser = Watir::Browser.new :phantomjs, :desired_capabilities => capabilities

        dimensions = Selenium::WebDriver::Dimension.new(1024, 768)
        browser.driver.manage.window.size = dimensions

        #browser = Selenium::WebDriver.for :phantamjs, :desired_capabilities => capabilities 
        #browser.get(url)
        browser.goto(url)
        screenshot_path = Rails.root.join('public/test.png')
        #browser.save_screenshot(screenshot_path)
        browser.screenshot.save(screenshot_path)
        @Json = {"result":"Success"}
      end
        
      respond_to do |format|
          format.html{render :json => @Json}
      end
  end

  def get_contact_email_by_order(c1, c2, c3)
      if c1 and c1.email
          c1.email
      elsif c2 and c2.email
          c2.email
      elsif c3 and c3.email
          c3.email
      else 
          "null"
      end
  end

  def get_contact_country_by_order(c1, c2, c3)
      if c1 and c1.country_code
          c1.country_code
      elsif c2 and c2.country_code
          c2.country_code
      elsif c3 and c3.country_code
          c3.country_code
      else 
          "null"
      end
  end

  def get_contact_org_by_order(c1, c2, c3)
      if c1 and c1.organization
          c1.organization
      elsif c2 and c2.organization
          c2.organization
      elsif c3 and c3.organization
          c3.organization
      else 
          "null"
      end
  end

  def get_domain_info_by_domain(domain)
      begin
          db_w = Domain.find_by_domain(domain)
      rescue Exception => exp
          db_w = nil
      end
  end
  
  def get_asn_info_by_ip(ip)
      begin
          db_w = IpAsnMapper.find_by_ip(ip)
      rescue Exception => exp
          db_w = nil
      end
  end
end
