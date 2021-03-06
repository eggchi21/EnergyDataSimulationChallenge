module Admins
  class HousesController < ApplicationController

    def new
    end

    def create
      if CsvHandler.import_csv(params[:csv_file].path, House)
        redirect_to new_admins_house_path, flash: { success: 'インポート成功！' }
      else
        render :new
      end
    end
  end
end
