require 'geocoder'
require 'rest_client'
require 'magic_eightball'
require_relative 'location'
require_relative 'constants'
require_relative 'irc_handlers'
require_relative 'forecasts'
require_relative 'utils'

module Lita
  module Handlers
    class OnewheelForecastIo < Handler
      config :api_key
      config :api_uri
      config :colors
      config :snowflake, default: '❄'

      include ::ForecastIo::Constants
      include ::ForecastIo::IrcHandlers
      include ::ForecastIo::Forecasts
      include ::ForecastIo::Utils

      # Temperature routes
      route(/^ansitemp\s*$/i, :handle_irc_ansitemp)
      route(/^ansitemp\s+(.+)/i, :handle_irc_ansitemp)
      route(/^dailytemp\s*$/i, :handle_irc_daily_temp)
      route(/^dailytemp\s+(.+)/i, :handle_irc_daily_temp)
      route(/^7day\s*$/i, :handle_irc_seven_day)
      route(/^7day\s+(.+)/i, :handle_irc_seven_day)
      route(/^weekly\s*$/i, :handle_irc_seven_day)
      route(/^weekly\s+(.+)/i, :handle_irc_seven_day)
      route(/^asciitemp\s*$/i, :handle_irc_ascii_temp)
      route(/^asciitemp\s+(.+)/i, :handle_irc_ascii_temp)
      route(/^ieeetemp\s*$/i, :handle_irc_ieeetemp)
      route(/^ieeetemp\s+(.+)/i, :handle_irc_ieeetemp)

      # General forecast routes
      route(/^forecastallthethings\s*$/i, :handle_irc_all_the_things)
      route(/^forecastallthethings\s+(.+)/i, :handle_irc_all_the_things)
      route(/^forecast\s*$/i, :handle_irc_forecast)
      route(/^forecast\s+(.+)/i, :handle_irc_forecast,
            help: { '!forecast [location]' => 'Text forecast of the location selected.'})
      route(/^weather\s*$/i, :handle_irc_forecast)
      route(/^weather\s+(.+)/i, :handle_irc_forecast,
            help: { '!weather [location]' => 'Alias for !forecast.'})
      route(/^condi*t*i*o*n*s*\s*$/i, :handle_irc_conditions)
      route(/^condi*t*i*o*n*s*\s+(.+)/i, :handle_irc_conditions)

      # One-offs
      route(/^rain\s*$/i, :is_it_raining)
      route(/^rain\s+(.+)/i, :is_it_raining)
      route(/^snow\s*$/i, :is_it_snowing)
      route(/^snow\s+(.+)/i, :is_it_snowing)
      route(/^geo\s*$/i, :handle_geo_lookup)
      route(/^geo\s+(.+)/i, :handle_geo_lookup)
      route(/^alerts\s*$/i, :handle_irc_alerts)
      route(/^alerts\s+(.+)/i, :handle_irc_alerts)
      route(/^neareststorm\s*$/i, :handle_irc_neareststorm)
      route(/^neareststorm\s+(.+)$/i, :handle_irc_neareststorm)

      # State Commands
      route(/^set scale (c|f|k)/i, :handle_irc_set_scale)
      route(/^set scale$/i, :handle_irc_set_scale)

      # Humidity
      route(/^ansihumidity\s*$/i, :handle_irc_ansi_humidity)
      route(/^ansihumidity\s+(.+)/i, :handle_irc_ansi_humidity)
      route(/^dailyhumidity\s*$/i, :handle_irc_daily_humidity)
      route(/^dailyhumidity\s+(.+)/i, :handle_irc_daily_humidity)

      # Rain related.  Where we all started.
      route(/^ansirain\s*$/i, :handle_irc_ansirain)
      route(/^ansirain\s+(.+)/i, :handle_irc_ansirain)
      route(/^ansisnow\s*$/i, :handle_irc_ansirain)
      route(/^ansisnow\s+(.+)/i, :handle_irc_ansirain)
      route(/^dailyrain\s*$/i, :handle_irc_daily_rain)
      route(/^dailyrain\s+(.+)/i, :handle_irc_daily_rain)
      route(/^dailysnow\s*$/i, :handle_irc_daily_rain)
      route(/^dailysnow\s+(.+)/i, :handle_irc_daily_rain)
      route(/^7dayrain\s*$/i, :handle_irc_seven_day_rain)
      route(/^7dayrain\s+(.+)/i, :handle_irc_seven_day_rain)
      route(/^weeklyrain\s*$/i, :handle_irc_seven_day_rain)
      route(/^weeklyrain\s+(.+)/i, :handle_irc_seven_day_rain)
      route(/^weeklysnow\s*$/i, :handle_irc_seven_day_rain)
      route(/^weeklysnow\s+(.+)/i, :handle_irc_seven_day_rain)
      route(/^ansiintensity\s*$/i, :handle_irc_ansirain_intensity)
      route(/^ansiintensity\s+(.+)/i, :handle_irc_ansirain_intensity)
      route(/^asciirain\s*$/i, :handle_irc_ascii_rain)
      route(/^asciirain\s+(.+)/i, :handle_irc_ascii_rain)

      # don't start singing.
      route(/^sunrise\s*$/i, :handle_irc_sunrise)
      route(/^sunrise\s+(.+)/i, :handle_irc_sunrise,
            help: { '!sunrise [location]' => 'Get today\'s sunrise time for [location].'})
      route(/^sunset\s*$/i, :handle_irc_sunset)
      route(/^sunset\s+(.+)/i, :handle_irc_sunset,
            help: { '!sunset [location]' => 'Get today\'s sunset time for [location].'})
      route(/^ansisun\s*$/i, :handle_irc_ansisun)
      route(/^ansisun\s+(.+)/i, :handle_irc_ansisun)
      route(/^dailysun\s*$/i, :handle_irc_dailysun)
      route(/^dailysun\s+(.+)/i, :handle_irc_dailysun)
      route(/^asciisun\s*$/i, :handle_irc_asciisun)
      route(/^asciisun\s+(.+)/i, :handle_irc_asciisun)

      # Mun!

      # Wind
      route(/^ansiwind\s*$/i, :handle_irc_ansiwind)
      route(/^ansiwind\s+(.+)/i, :handle_irc_ansiwind)
      route(/^asciiwind\s*$/i, :handle_irc_ascii_wind)
      route(/^asciiwind\s+(.+)/i, :handle_irc_ascii_wind)
      route(/^dailywind\s*$/i, :handle_irc_daily_wind)
      route(/^dailywind\s+(.+)/i, :handle_irc_daily_wind)

      # Cloud cover
      route(/^asciiclouds*\s+(.+)/i, :handle_irc_asciicloud)
      route(/^asciiclouds*\s*$/i, :handle_irc_asciicloud)
      route(/^ansiclouds*\s*$/i, :handle_irc_ansicloud)
      route(/^ansiclouds*\s+(.+)/i, :handle_irc_ansicloud)

      # oooOOOoooo
      route(/^ansiozone\s*$/i, :handle_irc_ansiozone)
      route(/^ansiozone\s+(.+)/i, :handle_irc_ansiozone)

      # Pressure
      route(/^ansipressure\s*$/i, :handle_irc_ansi_pressure)
      route(/^ansipressure\s+(.+)/i, :handle_irc_ansi_pressure)
      route(/^ansibarometer\s*$/i, :handle_irc_ansi_pressure)
      route(/^ansibarometer\s+(.+)/i, :handle_irc_ansi_pressure)
      route(/^dailypressure\s*$/i, :handle_irc_daily_pressure)
      route(/^dailypressure\s+(.+)/i, :handle_irc_daily_pressure)
      route(/^dailybarometer\s*$/i, :handle_irc_daily_pressure)
      route(/^dailybarometer\s+(.+)/i, :handle_irc_daily_pressure)

      route(/^weathercommands/i, :handle_irc_daily_pressure,
            help: { '!weathercommands' => 'A bunch more weather commands.' }
      )

    end

    Lita.register_handler(OnewheelForecastIo)
  end
end
