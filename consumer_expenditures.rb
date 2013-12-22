# From the BLS
# glossary => http://www.bls.gov/cex/csxgloss.htm

CONSUMER_DATA = {
  average_annual_expenditures: 
  {
    total: [48109, 49705, 51442, 3.3, 3.5],
    food: {
      total:[6129, 6458, 6599, 5.4, 2.2],
      at_home: [3624, 3838, 3921, 5.9, 2.2 ],
      away_from_home: [2505, 2620, 2678, 4.6, 2.2]
      },
    housing: [16557, 16803, 16887, 1.5, 0.5 ],
    apparel_and_services: [1700, 1740, 1736, 2.4, -0.2 ],
    transportation: [7677, 8293, 8998, 8.0, 8.5 ],
    health_care: [3157, 3313, 3556, 4.9, 7.3 ],
    entertainment: [2504, 2572, 2605, 2.7, 1.3 ],
    cash_contributions: [1633, 1721, 1913, 5.4, 11.2 ],
    personal_insurance_and_pensions: [5373, 5424, 5591, 0.9, 3.1 ],
    all_other_expenditures: [3379, 3382, 3557, 0.1, 5.2 ],
  },
  consumer_unit_characteristics: {
    number_of_consumer_units: [121107000, 122287000, 124416000],
    average_age_of_reference_person: [49.4, 49.7, 50.0 ],
    average_number_in_consumer_unit: {
      persons: [2.5, 2.5, 2.5 ],
      earners: [1.3, 1.3, 1.3 ],
      vehicles: [1.9, 1.9, 1.9 ],
    },
  percent_homeowner: [66, 65, 64 ],
  income_before_taxes: [62481, 63685, 65596, 1.9, 3.0]
  }
}

$top = 'average_annual_expenditures'
def consumer_expenditure(item, year, change=false)
  years = [2010, 2011, 2012]
  diffs = [2011, 2012]

  if change
    unless diffs.inclue? year
      raise "No change data for #{year}"
    end
  else
    unless years.include? year
      raise "No data for #{year}"
    end
  end

  nested_items = item.split(/\:/)
  data = CONSUMER_DATA
  until nested_items.empty?
    data = data[(nested_items.shift).to_sym]
    if data.nil?
      raise "Could not find item #{item}"
    end
  end

  if change
    data[diff.index(year)+3]
  else
    data[years.index(year)]
  end
end

def consumer_fraction(item, year)

  total = consumer_expenditure([$top, 'total'].join(':'),year)
  consumer_expenditure(item, year) / total.to_f
end

def consumer_fraction_all(year)
  total = consumer_expenditure([$top, 'total'].join(':'),year)

  categories = ['food:total',
    'food:at_home',
    'food:away_from_home',
    'housing',
    'apparel_and_services',
    'transportation',
    'health_care',
    'entertainment',
    'cash_contributions',
    'personal_insurance_and_pensions',
    'all_other_expenditures']
    
  max_len = categories.reduce(0) {|len, c| [len, c.length].max }

  categories.each do |item|
    printf "%#{max_len}s: %3.1f%%\n", item, consumer_expenditure([$top, item].join(':'), year)/total.to_f * 100
  end
  nil
end
