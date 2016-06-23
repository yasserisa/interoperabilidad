class ServiceVersionsController < ApplicationController
  before_action :set_service
  before_action :set_service_version, only: :show

  def show
  end

  def index
    @service_versions = @service.service_versions.order('version_number DESC')
  end

  def new
    if user_signed_in? && @service.can_be_updated_by?(current_user)
       @service_version = ServiceVersion.new
    else
      redirect_to service_service_versions_path(@service), notice: 'no tiene permisos suficientes'
    end
  end

  def create
    @service_version = @service.service_versions.build(service_version_params)
    @service_version.user = current_user
    if @service_version.save
      redirect_to [@service, @service_version], notice: 'service_version was successfully created.'
    else
      render :new
    end
  end

  def state
    new_state = params[:state]
    case new_state
    when 'current'
      make_current_version
    when 'rejected'
      reject_version
    else
      Rollbar.error('For ' + self.service.name + ' version ' +
        self.version_number + ' the new_state was: ' + new_state)
    end
  end

  def make_current_version
    set_service_version
    @service_version.make_current_version
    redirect_to services_path
  end

  def reject_version
    set_service_version
    @service_version.reject_version
    redirect_to services_path
  end

  private

  def service_version_params
    params.require(:service_version).permit(:spec_file, :backward_compatibility)
  end

  def set_service
    @service = Service.where(name: params[:service_name]).take
  end

  def set_service_version
    @service_version = @service.service_versions.where(version_number: params[:version_number]).take
  end
end
