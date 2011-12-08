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
require "redirectable_routing_switch/authenticator"


describe Authenticator do
  before :all do
    class Client < Controller
      attr_reader :authenticator


      def start
        @authenticator = Authenticator.instance
      end
    end
  end


  def self.db_file
    "#{ ENV[ 'TREMA_APPS' ] }/redirectable_routing_switch/authorized_host.db"
  end


  if File.exists?( db_file ) == true
    context "With a valid authentication file" do
      it "should authenticate a known mac address" do
        network {
          vswitch { datapath_id "0xe0" }
        }.run( Client ) {
          controller( "Client" ).authenticator.init( self.class.db_file )
          controller( "Client" ).authenticator.authenticate_mac( Trema::Mac.new( "00:00:00:00:10:01" ) ).should be_true
        }
      end


      it "should failed to authenticate an unknown mac address" do
        network {
          vswitch { datapath_id "0xe0" }
        }.run( Client ) {
          controller( "Client" ).authenticator.finalize
          controller( "Client" ).authenticator.init( self.class.db_file )
          controller( "Client" ).authenticator.authenticate_mac( Trema::Mac.new( "ff:ff:ff:ff:ff:ff" ) ).should be_false
        }
      end


      it "should finalize and initialize again" do
        network {
          vswitch { datapath_id "0xe0" }
        }.run( Client ) {
          controller( "Client" ).authenticator.finalize
          controller( "Client" ).authenticator.init( self.class.db_file )
          controller( "Client" ).authenticator.authenticate_mac( Trema::Mac.new( "00:00:00:00:10:01" ) ).should be_true
        }
      end
    end
  else
    pending "Authorized file not found: #{ db_file } tests disabled"
  end


  context "With an invalid authentication file" do
    it "should failed to authenticate mac address" do
      network {
        vswitch { datapath_id "0xe0" }
      }.run( Client ) {
        controller( "Client" ).authenticator.finalize
        controller( "Client" ).authenticator.init( "foo" )
        controller( "Client" ).authenticator.authenticate_mac( Trema::Mac.new( "00:00:00:00:10:01" ) ).should be_false
      }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
