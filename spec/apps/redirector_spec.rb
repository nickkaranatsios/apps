#
# Author: Nick Karanatsios <nickkaranatsios@gmail.com>
#
# Copyright (C) 2008-2011 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


require 'apps-spec-helper'


require "trema"
require "redirectable_routing_switch/redirector"


describe Redirector do
  if Process.uid != 0
    context "Without root privileges" do
      it "should raise error and not run any further tests" do
        lambda { Redirector.instance.init }.should raise_error( /Failed to initialize redirector/ )
      end
    end
  else
    before :all do
      class Client < Controller
        attr_reader :redirector


        def start
          @redirector = Redirector.instance
        end
      
      
        def packet_in datapath_id, message
          @redirector.redirect datapath_id, message
        end
      end
    end




    it "should re-initialize successfully" do
      network {
        vswitch( "client" ) { datapath_id "0xe0" }
        vhost "host1"
        vhost "host2"
        link "host1", "client"
        link "host2", "client"
      }.run( Client ) {
        controller( "Client" ).redirector.init
        controller( "Client" ).redirector.finalize
puts `netstat -i | grep of0`
puts `netstat -r`
        controller( "Client" ).redirector.init
        send_packets "host1", "host2"
        sleep 2 #FIXME wait for packets to be sent
        netstat_str =  `netstat -i | grep of0`
        rx_count = netstat_str.split( /\s+/ )[3].to_i
        rx_count.should >= 1
      }
    end


    it "should #redirect to of0" do
      network {
        vswitch( "client" ) { datapath_id "0xe0" }
        vhost "host1"
        vhost "host2"
        link "host1", "client"
        link "host2", "client"
      }.run( Client ) {
        send_packets "host1", "host2"
        sleep 2 #FIXME wait for packets to be sent
        netstat_str =  `netstat -i | grep of0`
        rx_count = netstat_str.split( /\s+/ )[3].to_i
        rx_count.should >= 1
      }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
