$:.unshift '/opt/netapp-manageability-sdk-5.0R1/lib/ruby/NetApp/'
require 'NaServer'

Puppet::Type.type(:vserver).provide(:vserver_provider) do
	desc 'ontapi connects to the controller'

	def exists?
		begin
                        hostname = resource[:cmgmt];
			username = resource[:vuser];
			password = resource[:vpass];
			port = resource[:port]; #80
			serverType = resource[:servertype]; #FILER
			transportType = resource[:transporttype] #"HTTP"

			server = NaServer.new(hostname,1,15)
			server.set_server_type(serverType)
			server.set_transport_type(transportType)
			server.set_port(port)
			server.set_style("LOGIN")
			server.set_admin_user(username, password)


			api = NaElement.new("vserver-get-iter")

			output = server.invoke_elem(api)
			if (output.results_status().eql?("failed"))
				    print ("Error:\n")
				        print (output.sprintf())
					    exit
			end

			text = output.sprintf.to_s
			if text.include? resource[:name]
				true
				exit
			else
				false
				exit
			end
		end
	end

	def create
		begin
                        hostname = resource[:cmgmt];
			username = resource[:vuser];
			password = resource[:vpass];
			port = resource[:port]; #80
			serverType = resource[:servertype]; #FILER
			transportType = resource[:transporttype] #"HTTP"

			server = NaServer.new(hostname,1,15)
			server.set_server_type(serverType)
			server.set_transport_type(transportType)
			server.set_port(port)
			server.set_style("LOGIN")
			server.set_admin_user(username, password)

			api = NaElement.new("vserver-create")
			api.child_add_string("vserver-name", resource[:name])
			api.child_add_string("root-volume", resource[:root_volume])
			api.child_add_string("root-volume-aggregate", resource[:root_volume_aggregate])

			nameserverswitchElement = NaElement.new("name-server-switch")
			api.child_add(nameserverswitchElement)
			nameserverswitchElement.child_add_string("nsswitch", resource[:name_server_switch])
			api.child_add_string("root-volume-security-style", resource[:root_volume_security_style])

			output = server.invoke_elem(api)
			if (output.results_status().eql?("failed"))
	   			print ("Error:\n")
	        		print (output.sprintf())
		    		exit
			end
			print ("Received:\n")
			print (output.sprintf())
		end
	end


	def destroy 
		begin
                        hostname = resource[:cmgmt];
			username = resource[:vuser];
			password = resource[:vpass];
			port = resource[:port]; #80
			serverType = resource[:servertype]; #FILER
			transportType = resource[:transporttype] #"HTTP"

			server = NaServer.new(hostname,1,15)
			server.set_server_type(serverType)
			server.set_transport_type(transportType)
			server.set_port(port)
			server.set_style("LOGIN")
			server.set_admin_user(username, password)

			#we need to stop the vserver
			api = NaElement.new("vserver-stop")
			api.child_add_string("vserver-name", resource[:name])

			output = server.invoke_elem(api)
			if (output.results_status().eql?("failed"))
			    print ("Error:\n")
			    print (output.sprintf())
			    exit
			end
			print ("Received:\n")
			print (output.sprintf())

			#lets destroy the vserver	
			api = NaElement.new("vserver-destroy")
			api.child_add_string("vserver-name", resource[:name])

			output = server.invoke_elem(api)
			if (output.results_status().eql?("failed"))
			    print ("Error:\n")
			    print (output.sprintf())
			    exit
			end
			print ("Received:\n")
			print (output.sprintf())

		end
	end
end
