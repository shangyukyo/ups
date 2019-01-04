# frozen_string_literal: true

module UPS
  SERVICES = {
    '01' => 'UPS Next Day Air',
    '02' => 'UPS 2nd Day Air',
    '03' => 'UPS Ground',
    '07' => 'UPS Worldwide Express',
    '08' => 'UPS Worldwide Expedited',
    '11' => 'UPS Standard',
    '12' => 'UPS 3 Day Select',
    '13' => 'UPS Next Day Air Saver',
    '14' => 'UPS Next Day Air Early AM',
    '54' => 'UPS Express Plus',
    '59' => 'UPS 2nd Day Air A.M.',
    '65' => 'UPS Worldwide Saver',
    '82' => 'UPS Today Standard',
    '83' => 'UPS Today Dedicated Courier',
    '84' => 'UPS Today Intercity',
    '85' => 'UPS Today Express',
    '86' => 'UPS Today Express Saver'
  }.freeze
end
