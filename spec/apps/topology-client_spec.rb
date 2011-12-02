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
require "topology_client"


module TopologyClient
  describe TopologyLinkStatus, ".new" do 
    its ( :from_dpid ) { should == 0 }
    its ( :to_dpid ) { should == 0 }
    its ( :from_portno ) { should == 0 }
    its ( :status ) { should == 0 }
  end


  describe TopologyLinkStatus, ".new( WITH ANY OPTION )" do
    subject { TopologyLinkStatus.new 123 }
    it "should raise ArgumentError" do
      expect { subject }.to raise_error( ArgumentError )
    end
  end


  describe TopologyPortStatus, ".new" do
    its ( :dpid ) { should == 0 }
    its ( :port_no ) { should == 0 }
    its ( :status ) { should == 0 }
    its ( :external ) { should == 0 }
  end


  describe TopologyPortStatus, ".new( WITH ANY OPTION )" do
    subject { TopologyPortStatus.new 123 }
    it "should raise ArgumentError" do
      expect { subject }.to raise_error( ArgumentError )
    end
  end
end


describe TopologyClient do
  before do
    class Client
      include Trema::Router
    end
    def client
      @client ||= Client.new
    end
    client.stub!( :name ).and_return( 'Client' )
    client.stub!( :init_topology_client ).and_return( true )
    client.stub!( :init_path_resolver_client ).and_return( true )
  end


  it "should respond to #init_topology_client" do
    client.should_receive( :init_topology_client ).with( 'Client' )
    client.start_topology
  end


  it "should notifier observers of topology changes" do
    # register observer
    client.start_router mock( 'options' )
    client.should_receive( :update ).once
    client.topology_notifier mock( 'port status message' ), :port
  end


  it "should raise an exception when unknown topology message" do
    expected_error = /An invalid topology change message received/  
    lambda { client.update mock( 'unknown message' ), :unknown }.should raise_error( expected_error )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
