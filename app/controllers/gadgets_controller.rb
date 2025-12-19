# frozen_string_literal: true

class GadgetsController < ApplicationController
  def index
    @gadgets = []
    Gadget.scan.each { |item| @gadgets << item }
  rescue => e
    @error = e
    @gadgets = []
  end

  def create
    id = params[:id].presence || SecureRandom.uuid
    version = params[:version].presence || "v1"
    name = params[:name].presence || "Unnamed"
    g = Gadget.new(id: id, version: version, name: name)
    g.save!
    redirect_to gadgets_path, notice: "Created gadget #{id}/#{version}"
  rescue => e
    redirect_to gadgets_path, alert: e.message
  end

  def destroy
    id = params[:id]
    version = params[:version]
    if id.present? && version.present?
      if (g = Gadget.find(id: id, version: version))
        g.delete!
        redirect_to gadgets_path, notice: "Deleted gadget #{id}/#{version}"
      else
        redirect_to gadgets_path, alert: "Gadget not found"
      end
    else
      redirect_to gadgets_path, alert: "Missing id or version"
    end
  end
end
