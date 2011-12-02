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
  describe HopInfo, ".new" do
    its ( :dpid ) { should == 0 }
    its ( :in_port_no ) { should == 0 }
    its ( :out_port_no ) { should == 0 }
  end


  describe HopInfo, ".new( WITH ANY OPTION )" do
    subject { HopInfo.new 123 }
    it "should raise ArgumentError" do
      expect { subject }.to raise_error( ArgumentError )
    end
  end
end


describe PathResolverClient do
  before do
    class Client
      include Trema::Router
    end
    def client
      @client ||= Client.new
    end
    client.stub!( :name ).and_return( 'Client' )
    client.stub!( :init_topology_client ).and_return( true )
#    client.stub!( :init_path_resolver_client ).and_return( true )
  end


=begin
  it "should respond to #init_path_resolver_client" do
    client.should_receive( :init_path_resolver_client )
    client.start_topology
  end
=end


  it "should resolve a specified path" do
    class Resolver < Controller; end
    network {
      vswitch { datapath_id "0xe0" }
      vswitch { datapath_id "0xe1" } 
      vswitch { datapath_id "0xe2" }
      vswitch { datapath_id "0xe3" }
      vswitch { datapath_id "0xe4" }
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

      vhost ("host3") {
        ip "192.168.0.3"
        netmask "255.255.0.0"
        mac "00:00:00:01:00:03"
      }

      vhost ("host4") {
        ip "192.168.0.4"
        netmask "255.255.0.0"
        mac "00:00:00:01:00:04"
      }

      vhost ("host5") {
        ip "192.168.0.5"
        netmask "255.255.0.0"
        mac "00:00:00:01:00:04"
      }

      link "0xe0", "host1"
      link "0xe1", "host2"
      link "0xe2", "host3"
      link "0xe3", "host4"
      link "0xe4", "host5"

      link "0xe0", "0xe1"
      link "0xe0", "0xe2"
      link "0xe0", "0xe4"

      link "0xe1", "0xe0"
      link "0xe1", "0xe3"
      link "0xe1", "0xe4"

      link "0xe2", "0xe0"
      link "0xe2", "0xe3"
      link "0xe2", "0xe4"

      link "0xe3", "0xe1"
      link "0xe3", "0xe2"
      link "0xe3", "0xe4"

      link "0xe4", "0xe0"
      link "0xe4", "0xe1"
      link "0xe4", "0xe2"
      link "0xe4", "0xe3"


      app {
        path "../apps/topology/topology"
      }


      app {
        path "../apps/topology/topology_discovery"
      }


      event :port_status => "topology", :packet_in => "filter", :state_notify => "topology"
      filter :lldp => "topology_discovery", :packet_in => "Resolver"
    }.run( Resolver ) {
      client.start_topology
      controller( "Resolver" ).should_receive( :packet_in ) do | datapath_id, message |
      end
      send_packets "host1", "host2"
      send_packets "host2", "host1"
    }
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
