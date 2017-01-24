class PeopleController < ApplicationController
  before_filter :load_person, :only => :show
  before_filter :load_people, :only => :index

  ## RESTful ACTIONS

  # Used by the API and various Person-only token inputs
  # Takes optional 'q' parameter to filter index
  def index
    authorize Person
    
    respond_to do |format|
      format.json { render json: @people }
    end
  end

  def show
    authorize @person
  
    respond_to do |format|
      format.json { render json: @person }
    end
  end

  ## Non-RESTful ACTIONS

  # 'search' queries _external_ databases (LDAP, etc.). GET /search?q=loginid (can be partial loginid, * will be appended)
  # If you wish to search the internal databases, use index with GET parameter q=..., e.g. /people?q=somebody
  def search
    authorize Person
  
    require 'ldap_helper'
    require 'ostruct'

    @results = []

    if params[:term]
      ldap = LdapHelper.new
      ldap.connect

      entries = ldap.search("(|(uid=#{params[:term]}*)(cn=#{params[:term]}*)(sn=#{params[:term]}*))")

      if entries
        entries.each do |entry|
          p = OpenStruct.new

          p.loginid = entry[:uid][0]
          p.first = entry[:givenName][0]
          p.last = entry[:sn][0]
          p.email = entry[:mail][0]
          p.phone = entry[:telephoneNumber][0]
          unless p.phone.nil?
            p.phone = p.phone.sub("+1 ", "").gsub(" ", "") # clean up number
          end
          p.address = entry[:street][0]
          p.name = entry[:displayName][0]
          p.imported = Person.exists?(:loginid => p.loginid)

          @results << p
        end
      else
        Rails.logger.warn "LDAP search attempted but ldap.search() is returning null. Is LDAP properly configured?"
      end
    end

    respond_to do |format|
      format.json { render "people/search" }
    end
  end

  # Imports a specific person from an external database. Use the above 'search' first to find possible imports
  def import
    authorize Person
    
    if params[:loginid]
      require 'ldap_helper'
      require 'ldap_person_helper'

      logger.tagged "people#import(#{params[:loginid]})" do
        if Person.find_by_loginid(params[:loginid]).present?
          logger.info "#{current_user.log_identifier}@#{request.remote_ip}: Importing existing user with loginid #{params[:loginid]}."
        else
          logger.info "#{current_user.log_identifier}@#{request.remote_ip}: Importing absent user with loginid #{params[:loginid]}."
        end

        import_start = Time.now

        if params[:loginid]
          ldap_import_start = Time.now

          ldap = LdapHelper.new
          ldap.connect

          results = ldap.search("(uid=" + params[:loginid] + ")")

          if results.length > 0
            @p = LdapPersonHelper.create_or_update_person_from_ldap_record(results[0], Rails.logger)
          end

          ldap_import_finish = Time.now
        end

        if @p
          @p.save

          import_finish = Time.now

          logger.info "Finished LDAP import request. LDAP operations took #{ldap_import_finish - ldap_import_start}s while the entire operation took #{import_finish - import_start}s."

          respond_to do |format|
            format.json { render json: @p }
          end
        else
          logger.error "Could not import person #{params[:loginid]}, no results from LDAP or error while saving."

          raise ActionController::RoutingError.new('Not Found')
        end
      end
    else
      logger.error "Invalid request for LDAP person import. Did not specify loginid."

      respond_to do |format|
        format.json { render json: nil, status: 400 }
      end
    end
  end

  private

    def load_person
        @person = Person.find_by_loginid(params[:id])
        @person = Person.find_by_id!(params[:id]) unless @person
    end

    def load_people
        if params[:q]
        people_table = Person.arel_table
        # Only show active people in the search. The group membership token input, for example, uses this method
        # to query people but it does not show deactivated people. This hides potential members and if they are
        # added again, it'll throw an error that the membership already exists.
        @people = Person.where(:active => true).where(people_table[:name].matches("%#{params[:q]}%").or(people_table[:loginid].matches("%#{params[:q]}%")).or(people_table[:first].matches("%#{params[:q]}%")).or(people_table[:last].matches("%#{params[:q]}%")))

        @people.map()
        else
        @people = Person.all
        end
    end
    
    def person_params
      params.require(:person).permit(:first, :last, :address, :email)
    end
end
