# frozen_string_literal: true

class WidgetsController < ApplicationController
  def index
    # Use aws-record model scan to list items
    @widgets = []
    Widget.scan.each { |item| @widgets << item }
  rescue => e
    @error = e
    @widgets = []
  end

  def create
    id = params[:id].presence || SecureRandom.uuid
    name = params[:name].presence || "Unnamed"
    w = Widget.new(id: id, name: name)
    w.save!
    redirect_to widgets_path, notice: "Created widget #{id}"
  rescue => e
    redirect_to widgets_path, alert: e.message
  end

  def destroy
    id = params[:id]
    if id.present?
      if (w = Widget.find(id: id))
        w.delete!
        redirect_to widgets_path, notice: "Deleted widget #{id}"
      else
        redirect_to widgets_path, alert: "Widget not found"
      end
    else
      redirect_to widgets_path, alert: "Missing id"
    end
  end
end
