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


describe PathResolverClient do
  before do
    class Client < Controller
      include Router
    end
    def client
      @client ||= Client.new
    end
    client.stub!( :name ).and_return( 'Client' )
    client.stub!( :init_topology_client ).and_return( true )
  end

  it "should respond to #init_path_resolver_client" do 
    client.should_receive( :init_path_resolver_client ).once
    client.start_topology
  end


  it "should have a valid handle after initialization" do
    client.start_topology
    client.handle?.should be_true
  end


  it "should failed to resolve an unconfigured path" do
    client.start_topology
    client.should_receive( :path_resolve ).and_return( nil )
    client.path_resolve( 0xe0, 1, 0xe1, 1 )
  end
end
    


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
