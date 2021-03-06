# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


@state_list = [{name: "Alabama"}, 
							{name: "Alaska"},
							{name: "Arizona"},
							{name: "Arkansas"}, 
							{name: "California"},
							{name: "Colorado"},
							{name: "Connecticut"}, 
							{name: "Delaware"},
							{name: "Florida"},
							{name: "Georgia"}, 
							{name: "Hawaii"},
							{name: "Idaho"}, 
							{name: "Illinois"}, 
							{name: "Indiana"}, 
							{name: "Iowa"}, 
							{name: "Kansas"},
							{name: "Kentucky"},
							{name: "Louisiana"}, 
							{name: "Maine"}, 
							{name: "Maryland"}, 
							{name: "Massachusetts"}, 
							{name: "Michigan"}, 
							{name: "Minnesota"},
							{name: "Mississippi"}, 
							{name: "Missouri"}, 
							{name: "Montana"}, 
							{name: "Nebraska"}, 
							{name: "Nevada"}, 
							{name: "New Hampshire"},
							{name: "New Jersey"}, 
							{name: "New Mexico"}, 
							{name: "New York"}, 
							{name: "North Carolina"}, 
							{name: "North Dakota"}, 
							{name: "Ohio"},
							{name: "Oklahoma"}, 
							{name: "Oregon"}, 
							{name: "Pennsylvania"}, 
							{name: "Rhode Island"}, 
							{name: "South Carolina"}, 
							{name: "South Dakota"},
							{name: "Tennessee"}, 
							{name: "Texas"}, 
							{name: "Utah"}, 
							{name: "Vermont"}, 
							{name: "Virginia"}, 
							{name: "Washington"},
							{name: "West Virginia"}, 
							{name: "Wisconsin"}, 
							{name: "Wyoming"}]


def load_state
	State.create(@state_list)
	puts'----------State Load successfully--------------------'
end


#load_state