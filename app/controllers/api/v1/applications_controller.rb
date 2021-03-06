module Api
  module V1
    class ApplicationsController < Api::V1::BaseController
      before_action :load_application, only: :show
      before_action :load_applications, only: :index

      # GET /applications
      def index
        logger.tagged('API') { logger.info "#{current_user.log_identifier}@#{request.remote_ip}: Loaded or searched applications index." }

        # API users currently share access to all resources. If this changes, we will need to alter our
        # cache_key to avoid leaking data across accounts via stale caches.
        if @applications.length > 0
          @cache_key = "api/application/" + (params[:q] ? params[:q] : '') + '/' + @applications.max_by(&:updated_at).updated_at.try(:utc).try(:to_s, :number).to_s
        end

        render "api/v1/applications/index"
      end

      # GET /applications/1
      def show
        if @application
          logger.tagged('API') { logger.info "#{current_user.log_identifier}@#{request.remote_ip}: Loaded application view (show) for #{@application.id}." }

          @cache_key = "api/application/" + @application.id.to_s + '/' + @application.updated_at.try(:utc).try(:to_s, :number)

          render "api/v1/applications/show"
        else
          logger.tagged('API') { logger.info "#{current_user.log_identifier}@#{request.remote_ip}: Attempted to load application view (show) for invalid ID #{@application_id}." }
          render plain: "Invalid application ID '#{@application_id}'.", status: 404
        end
      end

      private

        def load_application
          @application_id = params[:id].to_i # sanitize
          @application = Application.find_by_id(@application_id)
        end

        def load_applications
          if params[:q]
            apps = Application.arel_table
            @applications = Application.includes(:roles).where(apps[:name].matches("%#{params[:q]}%"))
          else
            @applications = Application.includes(:roles)
          end
        end

    end
  end
end
