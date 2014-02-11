Workflower
=========
This plugin enanche RoR by adding the possibility of handling workflows. By workflows, I mean a certain sequence of valid steps that we want the user to perform before achiving a result.

For instance, let's say you are building the checkout process in your new stunning e-commerce app. Clearly, you want the user to follow a certain path, i.e. go through the payments page, then the shipping page and finally the checkout page. 
But as a good developer, you are lazy and you don't feel like wasting your time implementing the logic the forces the user to follow that path and handles all the validations and redirections needed in these scenario. Instead, you just include this plugin in your app and you can get the behavior you are looking for just by typing:

``` ruby
workflow :checkout, singleton:true do |w|
    #first step - payment
		create_state w, controller: :checkout, action: :payment, redirect_to_wf: 'login'
    #secont step - shipping
		create_state w, conditions: valid_payment(params[:card_number]),
			 controller: :checkout, action: :shipment, redirect_to: '/checkout'
    #third step - submit order
		create_state w, conditions: valid_shipment(params[:shipping_ifo]),
			 controller: :checkout, action: :submit, redirect_to: '/checkout/shipment'	
end
```

More generally,
``` ruby
workflow :workflow_name, singleton:true|false do |w|
    ...
		create_state w, conditions: boolean,
			 controller: :controller_name, action: :action_name, redirect_to: '/checkout'
    ...
end
```

For more details, please read my 100pages dissertation :)
