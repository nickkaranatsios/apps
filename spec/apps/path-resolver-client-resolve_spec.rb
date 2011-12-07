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
require "trema/router"
require "path_resolver_client"


module PathResolverClient
  describe PathResolverClient, "#path_resolve" do
    class Resolver < Controller
      include Router


      def start
        start_router DummyOptions.new
      end


      class DummyOptions < Options
        def default_options
          {
            :idle_timeout => 60,
            :packet_in_discard_duration => 1
          }
        end


        def packet_in_discard_duration
          1
        end


        def idle_timeout
          60
        end
      end
    end


    it "should resolve a valid path" do
      network {
        vswitch { datapath_id "0xe0" }
        vswitch { datapath_id "0xe1" } 
        vhost ("host1") {
          ip "192.168.0.1"
          netmask "255.255.0.0"
          mac "00:00:00:00:10:01"
        }
        vhost ("host2") {
          ip "192.168.0.2"
          netmask "255.255.0.0"
          mac "00:00:00:00:10:02"
        }


        link "0xe0", "host1"
        link "0xe1", "host2"


        link "0xe0", "0xe1"
        link "0xe1", "0xe0"


        app {
          path "#{ ENV[ 'TREMA_APPS' ] }/topology/topology"
        }


        app {
          path "#{ ENV[ 'TREMA_APPS' ] }/topology/topology_discovery"
        }


        event :port_status => "topology", :packet_in => "filter", :state_notify => "topology"
        filter :lldp => "topology_discovery", :packet_in => "Resolver"
      }.run( Resolver ) {
        sleep 10 #wait for topology to start up
        controller( "Resolver" ).should_receive( :flood_packet ).at_least( :once )
        send_packets "host1", "host2"
        sleep 2 #wait for packets to be sent
        controller( "Resolver" ).should_receive( :path_resolve ).at_least( :once ).and_return( [ HopInfo.new ] )
        send_packets "host2", "host1"
        sleep 2 #wait for packets to be sent
      }
    end


    it "should fail to resolve an invalid path" do
      network {
        vswitch { datapath_id "0xe0" }
        vswitch { datapath_id "0xe1" } 
        vhost ("host1") {
          ip "192.168.0.1"
          netmask "255.255.0.0"
          mac "00:00:00:00:10:01"
        }
        vhost ("host2") {
          ip "192.168.0.2"
          netmask "255.255.0.0"
          mac "00:00:00:00:10:02"
        }


        link "0xe0", "host1"
        link "0xe1", "host2"


        link "0xe0", "0xe1"
        link "0xe1", "0xe0"


        app {
          path "#{ ENV[ 'TREMA_APPS' ] }/topology/topology"
        }


        app {
          path "#{ ENV[ 'TREMA_APPS' ] }/topology/topology_discovery"
        }


        event :port_status => "topology", :packet_in => "filter", :state_notify => "topology"
        filter :lldp => "topology_discovery", :packet_in => "Resolver"
      }.run( Resolver ) {
        controller( "Resolver" ).should_receive( :path_resolve ).and_return( nil )
        controller( "Resolver" ).path_resolve( 0xe0, 2, 0xe1, 2 )
      }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
