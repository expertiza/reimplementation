class Api::V1::VersionsController < ApplicationController
    include AuthorizationHelper

    before_action :authorize_admin!

    def index
      redirect_to action: :search
    end

    def show
      @version = Version.find_by(id: params[:id])
      if @version
        render json: @version
      else
        render json: { error: 'Version not found' }, status: :not_found
      end
    end

    def search
      @per_page = (params[:num_versions] || 25).to_i

      @versions = if params[:post]
                    paginate_list
                  else
                    Version.page(params[:page]).order('id').per(@per_page)
                  end

      render json: @versions
    end

    private

    def authorize_admin!
      render json: { error: 'Forbidden' }, status: :forbidden unless current_user_has_admin_privileges?
    end

    # For filtering the versions list with proper search and pagination.
    def paginate_list
      versions = Version.page(params[:page]).order('id').per(@per_page)
      versions = versions.where(id: params[:id]) if params[:id].to_i > 0
      if current_user_has_super_admin_privileges?
        versions = versions.where(whodunnit: params[:post][:user_id]) if params[:post][:user_id].to_i > 0
      end
      versions = versions.where(whodunnit: current_user.try(:id)) if current_user.try(:id).to_i > 0
      versions = versions.where(item_type: params[:post][:item_type]) if params[:post][:item_type] && params[:post][:item_type] != 'Any'
      versions = versions.where(event: params[:post][:event]) if params[:post][:event] && params[:post][:event] != 'Any'
      versions = versions.where('created_at >= ? and created_at <= ?', time_to_string(params[:start_time]), time_to_string(params[:end_time])) if params[:start_time] && params[:end_time]
      versions
    end

    def time_to_string(time)
      "#{time.tr('/', '-')}:00"
    end
  end