class Workflow::Engine

	
	workflow :login, singleton:true do |w|

		create_state w, conditions: %Q{true}, controller: :session, action: :first

		create_state w, conditions: %Q{valid_login(params[:username],params[:password])}, 
							controller: :session, action: :second, redirect_to: '/login'

		create_state w, conditions: %Q{valid_answer(params[:question])}, 
							controller: :session, action: :login, redirect_to: '/login'	
	end

	workflow :checkout, singleton:true do |w|

		create_state w, conditions: %Q{}, controller: :checkout, action: :payment, redirect_to_wf: 'login'

		create_state w, conditions: %Q{valid_payment(params[:card_number])},
			 controller: :checkout, action: :shipment, redirect_to: '/checkout'

		create_state w, conditions: %Q{valid_ship(params[:shipping_ifo])},
			 controller: :checkout, action: :submit, redirect_to: '/checkout/shipment'	
	end

	# workflow :wf3, singleton:true do |w|

	# 	create_state w, conditions: %Q{true}, controller: :static_pages, action: :step7, redirect_to: '/'
	# 	create_state w, conditions: %Q{true}, controller: :static_pages, action: :step8, redirect_to: '/step7'
	# 	create_state w, conditions: %Q{true}, controller: :static_pages, action: :step9, redirect_to: '/step8'	
	# end


end

