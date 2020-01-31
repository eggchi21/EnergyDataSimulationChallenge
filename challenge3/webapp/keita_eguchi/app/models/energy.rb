class Energy < ApplicationRecord
  belongs_to :house
  using ArrayStatistics

  scope :city_place, lambda { |city|
    city == 'All' ? all : joins(:house).where('houses.city = ?', city)
  }
  def self.monthly_average(energies)
    @monthly_energies = {}
    @monthly_group = energies.group_by(&:label)
    @temperatures = []
    @daylights = []
    @energy_productions = []

    @monthly_group.each_value do |value|
      @temperatures << value.map(&:temperature).average
      @daylights << value.map(&:daylight).average
      @energy_productions << value.map(&:energy_production).average
    end
    @monthly_energies = {
      labels: @monthly_group.keys,
      temperatures: @temperatures,
      daylights: @daylights,
      energy_productions: @energy_productions
    }
  end

  def self.one_of_cities_for_kind(energies,kind)
    kinds = ["temperature", "daylight" ,"energy_production"]
    @monthly_energies = {}
    @monthly_group = energies.group_by(&:label)
    @target_citykinds = []
    @all_citykinds = []
    @kind = kinds[kind.to_i - 1]

    @monthly_group.each_value do |value|
      eval("@target_citykinds << value.map(&:#{@kind}).average")
    end

    Energy.all.group_by(&:label).each_value do |value|
      eval("@all_citykinds<< value.map(&:#{@kind}).average")
    end
    @monthly_energies = {
      labels: @monthly_group.keys,
      target_citykinds: @target_citykinds,
      all_citykinds: @all_citykinds
    }
  end

  def self.all_kinds(energies, kind)
    kinds = ["temperature", "daylight" ,"energy_production"]
    @kind = kinds[kind.to_i - 1]

    @monthly_energies = {}
    @monthly_group = energies.group_by{|energy| [energy[:label], energy.house[:city]]}

    @london = []
    @cambridge = []
    @oxford = []

    @monthly_group.each do |key, value|
      case key[1]
      when 'London'
        eval("@london << value.map(&:#{@kind}).average")
      when 'Cambridge'
        eval("@cambridge << value.map(&:#{@kind}).average")
      when 'Oxford'
        eval("@oxford << value.map(&:#{@kind}).average")
      end
    end

    @monthly_energies = {
      labels: energies.group_by(&:label).keys,
      london: @london,
      cambridge: @cambridge,
      oxford: @oxford
    }
  end

end