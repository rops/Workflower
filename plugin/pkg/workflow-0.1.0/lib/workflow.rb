module Workflow
  @workflow_violated = false

  class << self
    attr_accessor :workflow_violated
  end

  def self.included(base)
    base.send :before_filter , :before_request
    base.send :before_render , :after_request
    base.send :after_filter , :after_render
  end

  def before_request

    Engine.before_filter(self,params[:controller],params[:action],params[:token_wf])
  end

  def after_request
    Engine.after_filter(self,params[:controller],params[:action])
  end

  def after_render
    response.body += Engine.inject_js(session)    
  end

  class Engine

    @@workflow_id = 0 #id counter
    @@name_maps = {} #(workflow_id,name)
    @@workflows = {}
    @@multiples = []
    @@states = {} #{"contr#action"=>{"wf1"=>st1, "wf2"=>st2}}
    @@initial_states = {} #{"contr#action"=>["wf1","wf2"]}
    @@final_states = {} #{'wf1':'contr#act'}
    def self.check_visited_state(next_state,controller,token)
      wf_id = next_state.workflow_id
      wf = @@workflows[wf_id]

      if is_singleton?(next_state)
        prev_state_name = controller.session['workflow'][wf_id]['current_state'] if controller.session['workflow'][wf_id]
      else
        prev_state_name = controller.session['workflow'][wf_id][token]['current_state'] if controller.session['workflow'][wf_id] && controller.session['workflow'][wf_id][token]
      end
      if !prev_state_name || prev_state_name.empty? #not in a working workflow
        #initial
        #if !@@initial_states[next_state.name].empty?
        if @@initial_states[next_state.name].include?(wf_id)
          # puts '#check_visited_state : Initial'
          return true
        else
          # puts '#check_visited_state: Intermediatte state'
          return false
        end
      else
        prev_state = @@states[prev_state_name][wf_id]
        offset = wf.index(next_state) - wf.index(prev_state)
        # puts "#check_visited_state : Offset #{offset}"
        return offset <= 1 # 0 = refresh..problems?
      end

    end


    def self.check_conditions(this_state,controller)

      conditions = this_state.conditions
      # puts conditions
      if controller.instance_eval conditions
        allow_access = true
      else
        allow_access = false
      end
    end

    def self.is_singleton?(state)
      return !@@multiples.include?(state.workflow_id)
    end

    def self.check_token(state,controller,token)
      if is_singleton?(state)
        return true
      end

      #if !@@initial_states[state.name].empty?
      if @@initial_states[state.name].include?(state.workflow_id)
        return true
      else
        if !token
          return false
        end
        wf_id = state.workflow_id
        wf = @@workflows[wf_id]
        return controller.session['workflow'][wf_id].include?(token)
      end

    end

    def self.get_possibile_states(name,session)



      possible_states = []
      #cerco tra tutti gli stati
      @@states[name].each do |wf,st|
        possible_states << st
      end
      # puts "possible: #{possible_states}"
      return possible_states
      #cerco solo tra gli iniziali e quelli dei wf attivi
      if @@initial_states[name] != nil
        
        @@initial_states[name].each do |wf|
          possible_states << @@states[name][wf]
        end
      end

      session.each do |wf,val|
          possible_states << @@states[name][wf] unless @@states[name][wf] == nil || @@initial_states[name].include?(wf)
      end

      return possible_states

    end

    def self.before_filter(controller,controller_name,action,token)
      # puts token
      # puts @@initial_states
      if !controller.session['workflow']
          controller.session['workflow'] = {}
      end
      name = "#{controller_name}\##{action}"
      if !@@states[name]
        return #nessun workflow
      end

      possible_states = get_possibile_states(name,controller.session['workflow']) 
      # puts "possible states: #{possible_states}"
      allowed_states = []
      denied_states = []
      possible_states.each do |state|
        allowed = check_visited_state(state,controller,token) && check_token(state,controller,token) && check_conditions(state,controller)

        if allowed
          allowed_states << state
        else
          denied_states << state
        end
      end

      # puts "allowed: #{allowed_states}"
      # puts "denied: #{denied_states}"

      if allowed_states.count == 0
        if denied_states.count == 1
          redirect(denied_states.first,controller,token)
        else
          denied_in_active_wf = []
          denied_states.each do |s|
            if controller.session['workflow'].include?(s.workflow_id)
              denied_in_active_wf << s
            end
          end
          if denied_in_active_wf.count == 1
            redirect(denied_in_active_wf.first,controller,token)
          else
            controller.redirect_to '/'
            controller.flash[:workflow] = "Workflow violation - Ambiguous Design. Back to Home"
          end
        end
      else
        new_token = ''
        allowed_states.each do |state|
          if !is_singleton?(state)
            if @@initial_states[state.name].include?(state.workflow_id)
              new_token = generate_token(state.workflow_id,controller.session['workflow'])
              controller.session['workflow_utils'] = {'current_token' => new_token }
            end
          end
        end
        allowed_states.each do |state|
          if controller.session['workflow'][state.workflow_id] == nil
            controller.session['workflow'][state.workflow_id] = {}
          end
          if is_singleton?(state)
            controller.session['workflow'][state.workflow_id] = {'pending_state'=>name}
          else
            if !new_token.empty?
              if token
                controller.session['workflow'][state.workflow_id][new_token] = controller.session['workflow'][state.workflow_id][token]
                controller.session['workflow'][state.workflow_id].delete(token)
              end
              controller.session['workflow'][state.workflow_id][new_token] = {'pending_state'=>name}
            else
              controller.session['workflow_utils']['current_token'] = token
              controller.session['workflow'][state.workflow_id][token] = {'pending_state'=>name}
            end
          end
        end
      end

      # puts controller.session['workflow']
      

    end

    def self.generate_token(wf_id,session)
      return SecureRandom.urlsafe_base64(10)
      if !session[wf_id]
        return SecureRandom.hex(5)
      end
      begin
        token = SecureRandom.hex(5)
      end while session[wf_id].include?(token)
      return token
    end


    def self.redirect (state,controller,token) 
      if state.redirect_to_wf
        wf_id = @@name_maps[state.redirect_to_wf.to_sym]
        if wf_id
          first_state = @@workflows[wf_id].first
          # puts 'Redirecting to Workflow'
          controller.redirect_to controller:first_state.controller, action:first_state.action
          # puts "WRONG - redirecting to #{first_state.name}"
          controller.flash[:workflow] = "Workflow violation - You skipped something! I redirected you to workflow #{state.redirect_to_wf} - #{first_state.name}"
          if !controller.session['workflow']['pending']
            controller.session['workflow']['pending'] = {}
          end        
          controller.session['workflow']['pending'][wf_id] = state.name #{current_wf : redirect_when_done}
          # puts "CODDIO"
          # puts controller.session['workflow']['pending']
        else
          # puts 'NON ESISTE IL WF'
        end
      else
        controller.redirect_to state.redirect
        # puts "WRONG - redirecting to #{state.redirect}"
        controller.flash[:workflow] = "Workflow violation - You skipped something! I brought you back to #{state.redirect}"
      end
    end

    def self.after_filter(controller,controller_name,action)
      # puts controller.response.body
      name = "#{controller_name}\##{action}"
      #aggiornare lo stato se workflow_violated = false
      # puts 'After'
      if Workflow.workflow_violated == false #not violated
        #set the current state as visited
        iter = controller.session['workflow'].clone
        iter.each do |wf,val|
          if @@final_states[wf] == name 
                  if controller.session['workflow']['pending'] && controller.session['workflow']['pending'][wf] #redirect if there is any pending wf
                    contr_name = controller.session['workflow']['pending'][wf]
                    controller.session['workflow']['pending'].delete(wf)
                    contr = contr_name.split('#').first
                    act = contr_name.split('#').last
                    controller.flash[:workflow] = "You completed workflow: #{wf}! I brought you back where you were before it!"
                    url = controller.url_for controller:contr, action:act
                    controller.response.location = url
                    controller.response.status = 302
                  end 
            end
          if !@@multiples.include?(wf)#singleton
            if controller.session['workflow'][wf]['pending_state'] == name
                 if @@final_states[wf] == name 
                #   if controller.session['workflow']['pending'] && controller.session['workflow']['pending'][wf] #redirect if there is any pending wf
                #     contr_name = controller.session['workflow']['pending'][wf]
                #     controller.session['workflow']['pending'].delete(wf)
                #     contr = contr_name.split('#').first
                #     act = contr_name.split('#').last
                #     controller.flash[:workflow] = "You completed workflow: #{wf}! I brought you back where you were before it!"
                #     url = controller.url_for controller:contr, action:act
                #     controller.response.location = url
                #     controller.response.status = 302
                #   end 
                  controller.session['workflow'].delete(wf) #terminate the workflow
                else
                  controller.session['workflow'][wf]['current_state'] = controller.session['workflow'][wf]['pending_state']
                  controller.session['workflow'][wf].delete('pending_state')
                end
            end
          else
            iter[wf].each do |token,val|       
              if controller.session['workflow'][wf][token]['pending_state'] == name
                 if @@final_states[wf] == name 
                #   if controller.session['workflow']['pending'] && controller.session['workflow']['pending'][wf] #redirect if there is any pending wf
                #     contr_name = controller.session['workflow']['pending'][wf]
                #     controller.session['workflow']['pending'].delete(wf)
                #     contr = contr_name.split('#').first
                #     act = contr_name.split('#').last
                #     controller.flash[:workflow] = "You completed workflow: #{wf}! I brought you back where you were before it!"
                #     url = controller.url_for controller:contr, action:act
                #     controller.response.location = url
                #     controller.response.status = 302
                #   end 
                  controller.session['workflow'][wf].delete(token) #terminate the workflow
                else
                  controller.session['workflow'][wf][token]['current_state'] = controller.session['workflow'][wf][token]['pending_state']
                  controller.session['workflow'][wf][token]['pending_state'] = ''
                end
                
              end
            end
          end
        end
        # puts controller.session['workflow']
        
      else
        # puts "WORKFLOW VIOLATION - INTERNAL ERROR"
        Workflow.workflow_violated = false
        controller.flash[:workflow] = "Workflow violation - Internal Error"
        #togliere pending?
      end


      
    end

    def self.workflow(name,options={singleton:false})
      singleton = options[:singleton]
      # puts "new workflow" + name.to_s
      #create workflow
      @@workflow_id = @@workflow_id + 1
      id = @@workflow_id
      @@name_maps[name] = id;
      @@workflows[id] = []
      if singleton == false
        @@multiples << id 
      end

      yield (id)
    end

    def self.create_state(workflow_id,params)
      # puts "new_state for workflow_id: #{workflow_id} #{@@name_maps[workflow_id]}"      
      conditions =  params[:conditions]
      controller = params[:controller]
      action = params[:action]
      redirect = params[:redirect_to]
      redirect_to_wf = params[:redirect_to_wf]
      s = State.new(workflow_id,conditions,controller,action,redirect,redirect_to_wf)
      @@workflows[workflow_id]  << s
      if !@@states[s.name]
        @@states[s.name] = {}
      end
      @@states[s.name][s.workflow_id] = s
      
      #@@initial_states[s.name] = s.workflow_id unless @@initial_states.values.include?(s.workflow_id)
      if !@@initial_states[s.name]
        @@initial_states[s.name] = []
      end
      @@initial_states[s.name] << s.workflow_id unless @@initial_states.values.flatten.include?(s.workflow_id)
      @@final_states[workflow_id] = s.name      

    end

    def self.get_current_token
    end

    def self.inject_js(session)
      # puts "INJECTO"
      # puts session
      if session['workflow_utils'] && session['workflow_utils']['current_token']
        new_token = session['workflow_utils']['current_token']
        session['workflow_utils'].delete('current_token')
        js_code = '<script type="text/javascript">$(function(){'
        js_code += "$('a').each(function() {this.href += (/\\?/.test(this.href) ? '&' : '?') + 'token_wf=#{new_token}';});"
        
        session['workflow'].each do |k,v|
          if session['workflow'][k][new_token]
            act = session['workflow'][k][new_token]['current_state'].split('#').last
            id = "\#w#{k}_#{act}"
            js_code += "$('#{id}').addClass('btn-success');" 
          elsif session['workflow'][k]['current_state']
            act = session['workflow'][k]['current_state'].split('#').last
            id = "\#w#{k}_#{act}"
            js_code += "$('#{id}').addClass('btn-success');" 
          end
        end


        js_code += ''
        js_code += '});</script>'
        return js_code
      else
        return ''
      end
      
    end


  end

  class State
    attr_accessor :id, :workflow_id, :conditions, :controller, :action, :redirect, :name, :redirect_to_wf

    @@state_id = {}

    def initialize(workflow_id,conditions,controller,action,redirect,redirect_to_wf)
      @id = getId(workflow_id)
      @workflow_id = workflow_id
      @conditions = conditions
      @controller = controller
      @action = action
      if redirect_to_wf
        @redirect_to_wf = redirect_to_wf
      else
        @redirect = redirect  
      end
      
      @name = "#{@controller}\##{@action}"
      # puts self.inspect
    end

    def getId(workflow_id)
      if !@@state_id[workflow_id]
        @@state_id[workflow_id] = 0        
      end

      @@state_id[workflow_id] = @@state_id[workflow_id] + 1  
      @@state_id[workflow_id]

    end


  end


end

class ActionController::Base
  include Workflow
  load('workflow_config.rb')
end

# module ApplicationHelper
#   # def link_to(*args)
#   #   if !args[2]
#   #     args[2] = {}
#   #   args[2][:token] = "ASDASD" 
#   #   super(*args)
#   # end
# end




